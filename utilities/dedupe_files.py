#!/usr/bin/env python3
"""
File Deduplication Script

Removes files from a second folder that already exist in a first folder,
based on file content (not filename). Uses MD5 hashing for comparison.

Usage:
    python dedupe_files.py /path/to/folder1 /path/to/folder2 [--delete] [--cache PATH] [--workers N]

By default, runs in dry-run mode (shows what would be deleted).
Use --delete to actually remove the duplicate files.

Use --cache to save scan results to a file. On subsequent runs with the same
--cache path, the script will load the cached results instead of rescanning.
This is useful for reviewing results before committing to deletion:

    1. Run with --cache to scan and review: 
       python dedupe_files.py ~/Backup1 ~/Backup2 --cache scan.json
    
    2. Run with --cache and --delete to delete using cached results:
       python dedupe_files.py ~/Backup1 ~/Backup2 --cache scan.json --delete

Use --workers to control the number of parallel processes for hashing. 
Defaults to half your CPU count. Increase for faster scans if your disk 
can keep up, or decrease if the system becomes unresponsive.
"""

import argparse
import hashlib
import json
import os
import sys
from collections import defaultdict
from concurrent.futures import ProcessPoolExecutor, as_completed
from multiprocessing import cpu_count
from pathlib import Path


def compute_file_hash(filepath: Path, chunk_size: int = 8192) -> str:
    """Compute MD5 hash of a file, reading in chunks for memory efficiency."""
    hasher = hashlib.md5()
    try:
        with open(filepath, "rb") as f:
            while chunk := f.read(chunk_size):
                hasher.update(chunk)
        return hasher.hexdigest()
    except (IOError, OSError) as e:
        print(f"  Warning: Could not read {filepath}: {e}", file=sys.stderr)
        return None


def get_file_size(filepath: Path) -> int | None:
    """Get file size, returning None if file cannot be accessed."""
    try:
        return filepath.stat().st_size
    except (IOError, OSError):
        return None


def scan_folder(folder: Path, workers: int) -> tuple[set[str], dict[int, list[Path]], int]:
    """
    Scan a folder recursively and return:
    - A set of file hashes
    - A dict mapping file sizes to file paths (for optimization)
    - Total file count
    """
    hashes = set()
    sizes_to_files: dict[int, list[Path]] = defaultdict(list)
    file_count = 0
    all_files = []
    
    print(f"Scanning: {folder}")
    
    for root, _, files in os.walk(folder):
        for filename in files:
            filepath = Path(root) / filename
            file_count += 1
            
            if file_count % 500 == 0:
                print(f"  Scanned {file_count} files...")
            
            size = get_file_size(filepath)
            if size is not None:
                sizes_to_files[size].append(filepath)
                all_files.append(filepath)
    
    print(f"  Found {file_count} files, computing hashes with {workers} workers...")
    
    # Compute hashes in parallel
    hashed_count = 0
    with ProcessPoolExecutor(max_workers=workers) as executor:
        future_to_path = {executor.submit(compute_file_hash, fp): fp for fp in all_files}
        
        for future in as_completed(future_to_path):
            file_hash = future.result()
            if file_hash:
                hashes.add(file_hash)
                hashed_count += 1
                
                if hashed_count % 500 == 0:
                    print(f"  Hashed {hashed_count} files...")
    
    print(f"  Completed: {len(hashes)} unique hashes from {file_count} files")
    return hashes, sizes_to_files, file_count


def find_duplicates(
    folder2: Path,
    folder1_hashes: set[str],
    folder1_sizes: dict[int, list[Path]],
    workers: int
) -> tuple[list[Path], int]:
    """
    Find files in folder2 that have matching hashes in folder1.
    Uses file size as a pre-filter for efficiency.
    Returns (duplicates list, total files scanned in folder2).
    """
    duplicates = []
    file_count = 0
    skipped_count = 0
    files_to_check = []
    
    print(f"\nComparing against: {folder2}")
    
    for root, _, files in os.walk(folder2):
        for filename in files:
            filepath = Path(root) / filename
            file_count += 1
            
            if file_count % 500 == 0:
                print(f"  Scanned {file_count} files...")
            
            size = get_file_size(filepath)
            if size is None:
                continue
            
            # Optimization: only compute hash if a file of this size exists in folder1
            if size not in folder1_sizes:
                skipped_count += 1
                continue
            
            files_to_check.append(filepath)
    
    print(f"  Scanned {file_count} files")
    print(f"  Skipped {skipped_count} files (no size match in folder1)")
    print(f"  Checking {len(files_to_check)} files with {workers} workers...")
    
    # Compute hashes in parallel and check for duplicates
    checked_count = 0
    with ProcessPoolExecutor(max_workers=workers) as executor:
        future_to_path = {executor.submit(compute_file_hash, fp): fp for fp in files_to_check}
        
        for future in as_completed(future_to_path):
            filepath = future_to_path[future]
            file_hash = future.result()
            checked_count += 1
            
            if checked_count % 500 == 0:
                print(f"  Checked {checked_count}/{len(files_to_check)} files, found {len(duplicates)} duplicates so far...")
            
            if file_hash and file_hash in folder1_hashes:
                duplicates.append(filepath)
    
    print(f"  Completed: checked {checked_count} files, found {len(duplicates)} duplicates")
    
    return duplicates, file_count


def format_size(size_bytes: int) -> str:
    """Format bytes as human-readable size."""
    for unit in ["B", "KB", "MB", "GB", "TB"]:
        if size_bytes < 1024:
            return f"{size_bytes:.2f} {unit}"
        size_bytes /= 1024
    return f"{size_bytes:.2f} PB"


def save_cache(cache_path: Path, folder1: Path, folder2: Path, duplicates: list[Path]) -> None:
    """Save scan results to a cache file."""
    cache_data = {
        "folder1": str(folder1),
        "folder2": str(folder2),
        "duplicates": [str(p) for p in duplicates]
    }
    with open(cache_path, "w") as f:
        json.dump(cache_data, f, indent=2)
    print(f"\nCache saved to: {cache_path}")


def load_cache(cache_path: Path, folder1: Path, folder2: Path) -> list[Path] | None:
    """
    Load scan results from a cache file.
    Returns None if cache is invalid or doesn't match the folders.
    """
    if not cache_path.exists():
        return None
    
    try:
        with open(cache_path, "r") as f:
            cache_data = json.load(f)
        
        # Verify the cache matches the requested folders
        if cache_data.get("folder1") != str(folder1):
            print(f"Cache folder1 mismatch: expected {folder1}, got {cache_data.get('folder1')}")
            return None
        if cache_data.get("folder2") != str(folder2):
            print(f"Cache folder2 mismatch: expected {folder2}, got {cache_data.get('folder2')}")
            return None
        
        duplicates = [Path(p) for p in cache_data.get("duplicates", [])]
        
        # Verify all files still exist
        missing = [p for p in duplicates if not p.exists()]
        if missing:
            print(f"Cache contains {len(missing)} files that no longer exist, rescanning...")
            return None
        
        return duplicates
    
    except (json.JSONDecodeError, KeyError) as e:
        print(f"Cache file is invalid: {e}")
        return None


def delete_files(files: list[Path]) -> tuple[int, int]:
    """
    Delete the specified files.
    Returns (deleted_count, total_size_freed).
    """
    deleted_count = 0
    total_size = 0
    total_files = len(files)
    
    print("Deleting duplicates...")
    
    for i, filepath in enumerate(files, 1):
        size = get_file_size(filepath)
        if size is not None:
            total_size += size
        
        try:
            filepath.unlink()
            deleted_count += 1
        except (IOError, OSError) as e:
            print(f"  Error deleting {filepath}: {e}", file=sys.stderr)
        
        if i % 500 == 0:
            print(f"  Deleted {i}/{total_files} files...")
    
    print(f"  Completed: deleted {deleted_count} files")
    
    return deleted_count, total_size


def remove_empty_dirs(folder: Path) -> int:
    """
    Remove empty directories within the given folder (bottom-up).
    Returns the number of directories removed.
    """
    removed_count = 0
    
    print("Removing empty directories...")
    
    # Walk bottom-up so we remove nested empty dirs first
    for root, dirs, files in os.walk(folder, topdown=False):
        for dirname in dirs:
            dirpath = Path(root) / dirname
            try:
                # rmdir only works on empty directories
                dirpath.rmdir()
                removed_count += 1
            except OSError:
                # Directory not empty or other error, skip it
                pass
    
    if removed_count > 0:
        print(f"  Removed {removed_count} empty directories")
    else:
        print(f"  No empty directories found")
    
    return removed_count


def main():
    parser = argparse.ArgumentParser(
        description="Remove duplicate files from folder2 that exist in folder1",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
    # Dry run (see what would be deleted):
    python dedupe_files.py ~/Backup1 ~/Backup2

    # Actually delete duplicates:
    python dedupe_files.py ~/Backup1 ~/Backup2 --delete

    # Dry run with caching (saves results to scan.json):
    python dedupe_files.py ~/Backup1 ~/Backup2 --cache scan.json

    # Delete using cached results (skips scanning):
    python dedupe_files.py ~/Backup1 ~/Backup2 --cache scan.json --delete

    # Use more workers for faster scanning (if disk I/O allows):
    python dedupe_files.py ~/Backup1 ~/Backup2 --workers 16

    # Use fewer workers to reduce system load:
    python dedupe_files.py ~/Backup1 ~/Backup2 --workers 4
        """
    )
    parser.add_argument("folder1", type=Path, help="Primary folder (files here are kept)")
    parser.add_argument("folder2", type=Path, help="Secondary folder (duplicates here will be removed)")
    parser.add_argument(
        "--delete", 
        action="store_true", 
        help="Actually delete files (default is dry-run mode)"
    )
    parser.add_argument(
        "--workers", "-w",
        type=int,
        default=max(1, cpu_count() // 2),
        help=f"Number of parallel workers (default: {max(1, cpu_count() // 2)})"
    )
    parser.add_argument(
        "--cache", "-c",
        type=Path,
        default=None,
        help="Path to cache file for saving/loading scan results (if omitted, no caching)"
    )
    
    args = parser.parse_args()
    
    # Validate folders
    if not args.folder1.is_dir():
        print(f"Error: {args.folder1} is not a valid directory", file=sys.stderr)
        sys.exit(1)
    
    if not args.folder2.is_dir():
        print(f"Error: {args.folder2} is not a valid directory", file=sys.stderr)
        sys.exit(1)
    
    # Resolve to absolute paths and check they're different
    folder1 = args.folder1.resolve()
    folder2 = args.folder2.resolve()
    
    if folder1 == folder2:
        print("Error: folder1 and folder2 cannot be the same directory", file=sys.stderr)
        sys.exit(1)
    
    # Check for nested folders (dangerous!)
    try:
        folder2.relative_to(folder1)
        print("Error: folder2 is inside folder1 - this is not allowed", file=sys.stderr)
        sys.exit(1)
    except ValueError:
        pass
    
    try:
        folder1.relative_to(folder2)
        print("Error: folder1 is inside folder2 - this is not allowed", file=sys.stderr)
        sys.exit(1)
    except ValueError:
        pass
    
    # Print mode
    if args.delete:
        print("=" * 60)
        print("WARNING: Running in DELETE mode - files will be permanently removed!")
        print("=" * 60)
    else:
        print("Running in DRY-RUN mode (no files will be deleted)")
        print("Use --delete flag to actually remove files")
    print()
    print(f"Using {args.workers} workers ({cpu_count()} CPUs available, use --workers to adjust)")
    print()
    
    # Try to load from cache
    duplicates = None
    folder1_count = None
    folder2_count = None
    
    if args.cache:
        duplicates = load_cache(args.cache, folder1, folder2)
        if duplicates is not None:
            print(f"Loaded {len(duplicates)} duplicates from cache: {args.cache}")
    
    # If no cache or cache not used, do the full scan
    if duplicates is None:
        # Step 1: Scan folder1
        folder1_hashes, folder1_sizes, folder1_count = scan_folder(folder1, args.workers)
        
        # Step 2: Find duplicates in folder2
        duplicates, folder2_count = find_duplicates(folder2, folder1_hashes, folder1_sizes, args.workers)
        
        # Save cache if path was provided
        if args.cache:
            save_cache(args.cache, folder1, folder2, duplicates)
    
    # Step 3: Delete (or report) duplicates
    if duplicates:
        print(f"\n{'=' * 60}")
        print("Summary:")
        if folder1_count is not None:
            print(f"  Files in folder1: {folder1_count}")
        if folder2_count is not None:
            print(f"  Files in folder2: {folder2_count}")
        print(f"  Duplicates found: {len(duplicates)}")
        
        if args.delete:
            total_size = sum(get_file_size(f) or 0 for f in duplicates)
            print(f"  Space to free: {format_size(total_size)}")
            print("=" * 60)
            
            # Confirm before deleting
            response = input("\nAre you sure you want to delete these files? (yes/no): ").strip().lower()
            
            if response == "yes":
                deleted_count, total_size = delete_files(duplicates)
                removed_dirs = remove_empty_dirs(folder2)
                print(f"\n{'=' * 60}")
                print(f"  Files deleted: {deleted_count}")
                print(f"  Empty directories removed: {removed_dirs}")
                print(f"  Space freed: {format_size(total_size)}")
                print("=" * 60)
            else:
                print("\nDeletion cancelled.")
        else:
            total_size = sum(get_file_size(f) or 0 for f in duplicates)
            print(f"  Space to free: {format_size(total_size)}")
            print("\nRun with --delete to remove these files")
            print("=" * 60)
    else:
        print("\nNo duplicates found!")
    
    return 0


if __name__ == "__main__":
    sys.exit(main())
