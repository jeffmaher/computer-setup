#Requires -RunAsAdministrator
# Bloatware Removal Script
# To Run: PowerShell -ExecutionPolicy Bypass -File .\remove_bloatware.ps1
#
# This script removes pre-installed Windows apps and bloatware
# Requires Administrator privileges

Write-Host ""
Write-Host "========================================" -ForegroundColor Red
Write-Host "Windows Bloatware Removal Tool" -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Red
Write-Host ""

Write-Host "This script will remove the following:" -ForegroundColor Yellow
Write-Host ""
Write-Host "Windows Store Apps:" -ForegroundColor Cyan
Write-Host "  - Bing News" -ForegroundColor Gray
Write-Host "  - Bing Search" -ForegroundColor Gray
Write-Host "  - Bing Weather" -ForegroundColor Gray
Write-Host "  - Microsoft To Do" -ForegroundColor Gray
Write-Host "  - Microsoft Solitaire Collection" -ForegroundColor Gray
Write-Host "  - Your Phone" -ForegroundColor Gray
Write-Host "  - Sticky Notes" -ForegroundColor Gray
Write-Host "  - Outlook for Windows" -ForegroundColor Gray
Write-Host ""
Write-Host "WinGet Bloatware:" -ForegroundColor Cyan
Write-Host "  - Microsoft OneDrive" -ForegroundColor Gray
Write-Host "  - Microsoft Teams" -ForegroundColor Gray
Write-Host ""
Write-Host "WARNING: This will remove these apps for ALL users on this computer!" -ForegroundColor Red
Write-Host ""

$confirm = Read-Host "Do you want to continue? (yes/no)"
if ($confirm -ne "yes") {
    Write-Host "Cancelled by user." -ForegroundColor Yellow
    exit
}

Write-Host ""
Write-Host "Starting bloatware removal..." -ForegroundColor Green
Write-Host ""

# Track removal stats
$storeAppsRemovedCount = 0
$storeAppsNotFoundCount = 0
$storeAppsFailedCount = 0
$wingetRemovedCount = 0
$wingetNotFoundCount = 0
$wingetFailedCount = 0

# ============================================================================
# WINDOWS STORE APPS REMOVAL
# ============================================================================

Write-Host "========================================" -ForegroundColor White
Write-Host "Removing Windows Store bloatware..." -ForegroundColor Red
Write-Host "========================================" -ForegroundColor White
Write-Host ""

# Windows Store apps to remove (using AppX commands)
$storeAppsToRemove = @(
    "Microsoft.BingNews",
    "Microsoft.BingSearch", 
    "Microsoft.BingWeather",
    "Microsoft.Todos",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.YourPhone",
    "Microsoft.MicrosoftStickyNotes",
    "Microsoft.OutlookForWindows"
)

foreach ($appName in $storeAppsToRemove) {
    Write-Host "Checking for $appName..." -ForegroundColor Cyan
    
    # Find all matching packages for all users
    $packages = Get-AppxPackage -Name "*$appName*" -AllUsers -ErrorAction SilentlyContinue
    
    if ($packages) {
        Write-Host "  Found $($packages.Count) package(s) matching $appName" -ForegroundColor Yellow
        
        foreach ($package in $packages) {
            Write-Host "  Attempting to remove: $($package.Name)" -ForegroundColor Red
            Write-Host "    Package Full Name: $($package.PackageFullName)" -ForegroundColor Gray
            
            try {
                Remove-AppxPackage -Package $package.PackageFullName -AllUsers -ErrorAction Stop
                Write-Host "    [OK] SUCCESS: $($package.Name) removed successfully" -ForegroundColor Green
                $storeAppsRemovedCount++
            } catch {
                Write-Host "    [FAILED] Could not remove $($package.Name)" -ForegroundColor Red
                Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor Red
                $storeAppsFailedCount++
            }
        }
    } else {
        Write-Host "  NOT FOUND: $appName not installed - skipping" -ForegroundColor Gray
        $storeAppsNotFoundCount++
    }
    Write-Host ""
}

# ============================================================================
# WINGET BLOATWARE REMOVAL
# ============================================================================

Write-Host "========================================" -ForegroundColor White
Write-Host "Removing WinGet bloatware..." -ForegroundColor Red
Write-Host "========================================" -ForegroundColor White
Write-Host ""

# WinGet manageable bloatware to remove
$wingetBloatware = @(
    @{ id = "Microsoft.OneDrive"; name = "Microsoft OneDrive" },
    @{ id = "Microsoft.Teams"; name = "Microsoft Teams" }
)

foreach ($app in $wingetBloatware) {
    Write-Host "Checking for $($app.name) ($($app.id))..." -ForegroundColor Cyan
    Write-Host "  Running: winget list --id $($app.id)" -ForegroundColor Gray
    
    # Check if app is installed
    $listResult = winget list --id $app.id --accept-source-agreements 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  FOUND: $($app.name) is installed" -ForegroundColor Yellow
        Write-Host "  Attempting removal with: winget uninstall $($app.id)" -ForegroundColor Red
        
        $uninstallResult = winget uninstall $app.id --silent --accept-source-agreements 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  [OK] SUCCESS: $($app.name) removed successfully" -ForegroundColor Green
            $wingetRemovedCount++
        } else {
            Write-Host "  [FAILED] Could not remove $($app.name)" -ForegroundColor Red
            Write-Host "  Exit code: $LASTEXITCODE" -ForegroundColor Red
            Write-Host "  Output: $uninstallResult" -ForegroundColor Gray
            $wingetFailedCount++
        }
    } else {
        Write-Host "  NOT FOUND: $($app.name) not installed - skipping" -ForegroundColor Gray
        $wingetNotFoundCount++
    }
    Write-Host ""
}

# ============================================================================
# SUMMARY
# ============================================================================

Write-Host ""
Write-Host "========================================" -ForegroundColor White
Write-Host "Bloatware Removal Summary" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor White
Write-Host ""

Write-Host "Windows Store Apps:" -ForegroundColor Cyan
Write-Host "  Removed:       $storeAppsRemovedCount" -ForegroundColor Green
Write-Host "  Not found:     $storeAppsNotFoundCount" -ForegroundColor Gray
Write-Host "  Failed:        $storeAppsFailedCount" -ForegroundColor Red
Write-Host ""

Write-Host "WinGet Apps:" -ForegroundColor Cyan
Write-Host "  Removed:       $wingetRemovedCount" -ForegroundColor Green
Write-Host "  Not found:     $wingetNotFoundCount" -ForegroundColor Gray
Write-Host "  Failed:        $wingetFailedCount" -ForegroundColor Red
Write-Host ""

$totalRemoved = $storeAppsRemovedCount + $wingetRemovedCount
$totalFailed = $storeAppsFailedCount + $wingetFailedCount

if ($totalFailed -gt 0) {
    Write-Host "Some apps could not be removed. Common reasons:" -ForegroundColor Yellow
    Write-Host "  - App is currently running (close and try again)" -ForegroundColor Gray
    Write-Host "  - App is a system component that can't be removed" -ForegroundColor Gray
    Write-Host "  - Insufficient permissions (ensure you ran as admin)" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor White
Write-Host "Bloatware removal complete!" -ForegroundColor Green
Write-Host "Total apps removed: $totalRemoved" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor White
Write-Host ""

if ($totalRemoved -gt 0) {
    Write-Host "Recommendation: Restart your computer to complete the cleanup." -ForegroundColor Yellow
    Write-Host ""
    $restart = Read-Host "Restart now? (y/n)"
    if ($restart -eq "y") {
        Write-Host "Restarting in 10 seconds... (Press Ctrl+C to cancel)" -ForegroundColor Yellow
        Start-Sleep -Seconds 10
        Restart-Computer -Force
    }
}
