#Requires -RunAsAdministrator
# WSL Installation Script
# To Run: PowerShell -ExecutionPolicy Bypass -File .\install_wsl.ps1
#
# This script installs Windows Subsystem for Linux (WSL) with Ubuntu

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "WSL Installation Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "This script will:" -ForegroundColor Yellow
Write-Host "  1. Enable Windows Subsystem for Linux feature" -ForegroundColor Gray
Write-Host "  2. Enable Virtual Machine Platform feature" -ForegroundColor Gray
Write-Host "  3. Update WSL to version 2" -ForegroundColor Gray
Write-Host "  4. Install Ubuntu Linux distribution" -ForegroundColor Gray
Write-Host ""
Write-Host "Note: A restart will be required after enabling Windows features." -ForegroundColor Yellow
Write-Host ""

$confirm = Read-Host "Do you want to continue? (y/n)"
if ($confirm -ne "y") {
    Write-Host "Installation cancelled." -ForegroundColor Yellow
    exit
}

Write-Host ""
Write-Host "Starting WSL installation..." -ForegroundColor Green
Write-Host ""

# ============================================================================
# Step 1: Enable WSL and Virtual Machine Platform Features
# ============================================================================

Write-Host "========================================" -ForegroundColor White
Write-Host "Step 1: Enabling Windows Features" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor White
Write-Host ""

Write-Host "Checking if WSL features are already enabled..." -ForegroundColor Cyan

# Check if WSL feature is enabled
$wslFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -ErrorAction SilentlyContinue
$vmFeature = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -ErrorAction SilentlyContinue

$needsRestart = $false

if ($wslFeature.State -eq "Enabled") {
    Write-Host "[OK] Windows Subsystem for Linux is already enabled" -ForegroundColor Green
} else {
    Write-Host "Enabling Windows Subsystem for Linux..." -ForegroundColor Yellow
    try {
        dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
        Write-Host "[OK] Windows Subsystem for Linux enabled" -ForegroundColor Green
        $needsRestart = $true
    } catch {
        Write-Host "[FAILED] Could not enable WSL feature: $_" -ForegroundColor Red
        exit 1
    }
}

if ($vmFeature.State -eq "Enabled") {
    Write-Host "[OK] Virtual Machine Platform is already enabled" -ForegroundColor Green
} else {
    Write-Host "Enabling Virtual Machine Platform..." -ForegroundColor Yellow
    try {
        dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
        Write-Host "[OK] Virtual Machine Platform enabled" -ForegroundColor Green
        $needsRestart = $true
    } catch {
        Write-Host "[FAILED] Could not enable Virtual Machine Platform: $_" -ForegroundColor Red
        exit 1
    }
}

# ============================================================================
# Step 2: Check if Restart is Needed
# ============================================================================

if ($needsRestart) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "RESTART REQUIRED" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Windows features have been enabled, but a restart is required." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "After restarting:" -ForegroundColor Cyan
    Write-Host "  1. Run this script again to complete WSL installation" -ForegroundColor Gray
    Write-Host "  2. The script will skip the feature installation step" -ForegroundColor Gray
    Write-Host "  3. WSL and Ubuntu will be installed automatically" -ForegroundColor Gray
    Write-Host ""
    
    $restart = Read-Host "Restart now? (y/n)"
    if ($restart -eq "y") {
        Write-Host "Restarting in 10 seconds... (Press Ctrl+C to cancel)" -ForegroundColor Yellow
        Start-Sleep -Seconds 10
        Restart-Computer -Force
    } else {
        Write-Host ""
        Write-Host "Please restart your computer manually, then run this script again." -ForegroundColor Yellow
        Write-Host ""
    }
    exit 0
}

# ============================================================================
# Step 3: Update WSL
# ============================================================================

Write-Host ""
Write-Host "========================================" -ForegroundColor White
Write-Host "Step 2: Updating WSL" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor White
Write-Host ""

Write-Host "Updating WSL to the latest version..." -ForegroundColor Cyan
try {
    wsl --update
    Write-Host "[OK] WSL updated successfully" -ForegroundColor Green
} catch {
    Write-Host "[WARNING] WSL update may have failed, but installation can continue" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Setting WSL default version to 2..." -ForegroundColor Cyan
try {
    wsl --set-default-version 2
    Write-Host "[OK] WSL default version set to 2" -ForegroundColor Green
} catch {
    Write-Host "[WARNING] Could not set default WSL version" -ForegroundColor Yellow
}

# ============================================================================
# Step 4: Install Ubuntu
# ============================================================================

Write-Host ""
Write-Host "========================================" -ForegroundColor White
Write-Host "Step 3: Installing Ubuntu" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor White
Write-Host ""

# Check if Ubuntu is already installed
$ubuntuInstalled = wsl --list --quiet 2>&1 | Select-String -Pattern "Ubuntu" -Quiet

if ($ubuntuInstalled) {
    Write-Host "[OK] Ubuntu is already installed" -ForegroundColor Green
    Write-Host ""
    Write-Host "Installed WSL distributions:" -ForegroundColor Cyan
    wsl --list --verbose
    Write-Host ""
} else {
    Write-Host "Installing Ubuntu Linux distribution..." -ForegroundColor Yellow
    Write-Host "This may take several minutes..." -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "IMPORTANT: Ubuntu Setup Coming Next" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "After download completes, Ubuntu will start IN THIS WINDOW." -ForegroundColor Cyan
    Write-Host "You'll be prompted to:" -ForegroundColor Cyan
    Write-Host "  1. Create a Linux username (lowercase, no spaces recommended)" -ForegroundColor Gray
    Write-Host "  2. Create a Linux password (type it twice)" -ForegroundColor Gray
    Write-Host "  3. Password won't show while typing - this is NORMAL!" -ForegroundColor Gray
    Write-Host ""
    Write-Host "After you create your account:" -ForegroundColor Cyan
    Write-Host "  - You'll see a Linux command prompt (username@computername:~$)" -ForegroundColor Gray
    Write-Host "  - Type 'exit' and press Enter to return to this script" -ForegroundColor Gray
    Write-Host "  - The script will then continue with next steps" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Starting installation now..." -ForegroundColor Yellow
    Write-Host ""
    
    try {
        # Install Ubuntu
        wsl --install -d Ubuntu
        
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "Ubuntu Setup Complete!" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        Write-Host ""
        
    } catch {
        Write-Host "[FAILED] Could not install Ubuntu: $_" -ForegroundColor Red
        Write-Host ""
        Write-Host "You can try installing Ubuntu manually:" -ForegroundColor Yellow
        Write-Host "  1. Open Microsoft Store" -ForegroundColor Gray
        Write-Host "  2. Search for 'Ubuntu'" -ForegroundColor Gray
        Write-Host "  3. Click 'Get' or 'Install'" -ForegroundColor Gray
        exit 1
    }
}

# ============================================================================
# Step 5: Verify Installation
# ============================================================================

Write-Host ""
Write-Host "========================================" -ForegroundColor White
Write-Host "Verifying Installation" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor White
Write-Host ""

Write-Host "Checking WSL installation..." -ForegroundColor Cyan
try {
    $wslVersion = wsl --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] WSL is installed and working" -ForegroundColor Green
    }
} catch {
    Write-Host "[WARNING] Could not verify WSL version" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Installed distributions:" -ForegroundColor Cyan
wsl --list --verbose

# ============================================================================
# Step 6: Post-Installation Instructions
# ============================================================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "WSL Installation Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Update Ubuntu packages (RECOMMENDED - run these commands now):" -ForegroundColor Yellow
Write-Host "   Open Ubuntu and run these commands:" -ForegroundColor Gray
Write-Host ""
Write-Host "   wsl" -ForegroundColor Green
Write-Host "   sudo apt update && sudo apt upgrade -y" -ForegroundColor Green
Write-Host "   sudo apt install zip unzip -y" -ForegroundColor Green
Write-Host "   exit" -ForegroundColor Green
Write-Host ""
Write-Host "2. Open Ubuntu anytime:" -ForegroundColor Yellow
Write-Host "   - Search 'Ubuntu' in Start Menu, or" -ForegroundColor Gray
Write-Host "   - Type 'wsl' in any terminal, or" -ForegroundColor Gray
Write-Host "   - Open Windows Terminal and select Ubuntu profile" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Set Ubuntu as default in Windows Terminal (optional):" -ForegroundColor Yellow
Write-Host "   - Open Windows Terminal" -ForegroundColor Gray
Write-Host "   - Click the down arrow next to the + (new tab)" -ForegroundColor Gray
Write-Host "   - Go to Settings" -ForegroundColor Gray
Write-Host "   - Change 'Default profile' to 'Ubuntu'" -ForegroundColor Gray
Write-Host "   - Click Save" -ForegroundColor Gray
Write-Host ""

Write-Host "Useful WSL commands:" -ForegroundColor Cyan
Write-Host "  wsl                    - Start default Linux distribution" -ForegroundColor Gray
Write-Host "  wsl --list --verbose   - List installed distributions" -ForegroundColor Gray
Write-Host "  wsl --shutdown         - Shutdown all WSL instances" -ForegroundColor Gray
Write-Host "  wsl --update           - Update WSL to latest version" -ForegroundColor Gray
Write-Host ""

Write-Host "========================================" -ForegroundColor White
Write-Host "Installation script complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor White
