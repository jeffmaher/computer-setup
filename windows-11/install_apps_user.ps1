# User-Scope Installation Script (Minimal Admin Required)
# To Run: PowerShell -ExecutionPolicy Bypass -File .\install_apps_user.ps1
#
# IMPORTANT NOTES:
# - This script runs as a STANDARD USER (not admin)
# - Most apps install to your user profile (C:\Users\jeff\AppData\Local)
# - Some apps (LibreOffice, VLC, Zoom, Docker) will show UAC prompts
# - When UAC prompts appear, enter your admin password to continue
# - The script will continue automatically after you approve each prompt
# - Apps will only be available for your user account
# - Updates won't require admin password (except Docker)

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Application Installer" -ForegroundColor Cyan
Write-Host "Minimal admin interaction required" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as admin (we DON'T want admin)
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($isAdmin) {
    Write-Host "WARNING: You are running this as Administrator!" -ForegroundColor Yellow
    Write-Host "This script is designed to run as a STANDARD USER." -ForegroundColor Yellow
    Write-Host "Apps will install system-wide instead of user-only." -ForegroundColor Yellow
    Write-Host ""
    $continue = Read-Host "Continue anyway? (y/n)"
    if ($continue -ne "y") {
        Write-Host "Exiting..." -ForegroundColor Red
        exit
    }
}

Write-Host "IMPORTANT: During installation, you may see UAC prompts for:" -ForegroundColor Yellow
Write-Host "  - If the script stalls, look for a blinking shield on your task bar" -ForegroundColor Gray
Write-Host "  - Click the shield and enter your admin password when prompted" -ForegroundColor Gray
Write-Host "  - The script will continue automatically after each prompt" -ForegroundColor Gray
Write-Host ""
$confirm = Read-Host "Ready to begin? (y/n)"
if ($confirm -ne "y") {
    Write-Host "Installation cancelled." -ForegroundColor Yellow
    exit
}
Write-Host ""

# Array of applications to install (user-scope preferred)
# tryMachineScope = true means if user-scope fails, try without --scope flag
$apps = @(
    @{ id = "Microsoft.VisualStudioCode"; name = "VS Code"; tryMachineScope = $false },
    @{ id = "TheDocumentFoundation.LibreOffice"; name = "LibreOffice"; tryMachineScope = $true },
    @{ id = "Microsoft.PowerToys"; name = "Microsoft PowerToys"; tryMachineScope = $false },
    @{ id = "VideoLAN.VLC"; name = "VLC Media Player"; tryMachineScope = $true },
    #@{ id = "OpenWhisperSystems.Signal"; name = "Signal"; tryMachineScope = $false },
    #@{ id = "OpenWhisperSystems.Signal.Beta"; name = "Signal Beta"; tryMachineScope = $false },
    #@{ id = "SlackTechnologies.Slack"; name = "Slack"; tryMachineScope = $false },
    #@{ id = "Google.Chrome"; name = "Google Chrome"; tryMachineScope = $true }, # This doesn't work
    #@{ id = "Mozilla.Firefox"; name = "Firefox"; tryMachineScope = $true },
    #@{ id = "AgileBits.1Password"; name = "1Password"; tryMachineScope = $true },
    #@{ id = "Doist.Todoist"; name = "Todoist"; tryMachineScope = $false },
    #@{ id = "Zoom.Zoom"; name = "Zoom"; tryMachineScope = $true },
    #@{ id = "Figma.Figma"; name = "Figma"; tryMachineScope = $false },
    #@{ id = "Docker.DockerDesktop"; name = "Docker Desktop"; tryMachineScope = $true },
    #@{ id = "Logitech.OptionsPlus"; name = "Logi Options+"; tryMachineScope = $true }
)

Write-Host "========================================" -ForegroundColor White
Write-Host "Installing applications..." -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor White
Write-Host ""
Write-Host "Preferred install location: $env:LOCALAPPDATA\Programs (user-scope)" -ForegroundColor Cyan
Write-Host "Some apps may fall back to system-wide if user-scope is not supported" -ForegroundColor Yellow
Write-Host ""

$installedCount = 0
$skippedCount = 0
$failedCount = 0
$machineInstallCount = 0

# Install apps
foreach ($app in $apps) {
    Write-Host "Checking $($app.name) ($($app.id))..." -ForegroundColor Cyan
    
    Write-Host "  Checking if already installed..." -ForegroundColor Gray
    $installed = winget list --id $app.id --accept-source-agreements 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] ALREADY INSTALLED: $($app.name) is already installed - skipping" -ForegroundColor Green
        $skippedCount++
        Write-Host ""
        continue
    }
    
    # Try user-scope installation first
    Write-Host "  Installing $($app.name) in user scope..." -ForegroundColor Yellow
    
    $installCmd = "winget install $($app.id) --scope user --silent --accept-package-agreements --accept-source-agreements"
    
    if ($app.version) {
        $installCmd += " --version `"$($app.version)`""
        Write-Host "    Using specific version: $($app.version)" -ForegroundColor Cyan
    }
    
    Write-Host "  Command: $installCmd" -ForegroundColor Gray
    
    $installResult = Invoke-Expression "$installCmd 2>&1"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] SUCCESS: $($app.name) installed successfully (user-scope)" -ForegroundColor Green
        $installedCount++
    } elseif ($LASTEXITCODE -eq -1978335216 -and $app.tryMachineScope) {
        # Error code 0x8A15002C means installer doesn't support user-scope
        # Try without --scope flag (will install system-wide, may require admin)
        Write-Host "  [INFO] User-scope not supported, trying system-wide installation..." -ForegroundColor Yellow
        
        $machineCmdInstall = "winget install $($app.id) --silent --accept-package-agreements --accept-source-agreements"
        if ($app.version) {
            $machineCmdInstall += " --version `"$($app.version)`""
        }
        
        Write-Host "  Command: $machineCmdInstall" -ForegroundColor Gray
        $machineResult = Invoke-Expression "$machineCmdInstall 2>&1"
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  [OK] SUCCESS: $($app.name) installed (system-wide)" -ForegroundColor Green
            Write-Host "      Note: Installed to Program Files, may require admin for updates" -ForegroundColor Gray
            $installedCount++
            $machineInstallCount++
        } else {
            Write-Host "  [FAILED] Failed to install $($app.name) (both user and system-wide)" -ForegroundColor Red
            Write-Host "  Exit code: $LASTEXITCODE" -ForegroundColor Red
            Write-Host "  This app may require manual installation with admin rights" -ForegroundColor Yellow
            $failedCount++
        }
    } else {
        Write-Host "  [FAILED] Failed to install $($app.name)" -ForegroundColor Red
        Write-Host "  Exit code: $LASTEXITCODE" -ForegroundColor Red
        Write-Host "  Output: $installResult" -ForegroundColor Gray
        
        if ($LASTEXITCODE -eq -1978335216) {
            Write-Host "  Note: This app doesn't support user-scope installation" -ForegroundColor Yellow
            Write-Host "        You may need to install it manually with admin rights" -ForegroundColor Yellow
        }
        
        $failedCount++
    }
    Write-Host ""
}

# Summary
Write-Host ""
Write-Host "========================================" -ForegroundColor White
Write-Host "Installation Summary" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor White
Write-Host "Successfully installed:  $installedCount apps" -ForegroundColor Green
Write-Host "Already installed:       $skippedCount apps" -ForegroundColor Cyan
Write-Host "Failed to install:       $failedCount apps" -ForegroundColor Red
if ($machineInstallCount -gt 0) {
    Write-Host "System-wide installs:    $machineInstallCount apps (user-scope not supported)" -ForegroundColor Yellow
}
Write-Host ""

if ($machineInstallCount -gt 0) {
    Write-Host "Note: Some apps installed system-wide:" -ForegroundColor Yellow
    Write-Host "  - These apps are in C:\Program Files" -ForegroundColor Gray
    Write-Host "  - Updates may require admin password" -ForegroundColor Gray
    Write-Host "  - This is because the app installers don't support user-scope" -ForegroundColor Gray
    Write-Host ""
}

if ($failedCount -gt 0) {
    Write-Host "Some installations failed. Common reasons:" -ForegroundColor Yellow
    Write-Host "  - App doesn't support user-scope or system-wide installation via winget" -ForegroundColor Gray
    Write-Host "  - Network issues during download" -ForegroundColor Gray
    Write-Host "  - App requires manual installation from website" -ForegroundColor Gray
    Write-Host ""
    Write-Host "For failed apps, try:" -ForegroundColor Cyan
    Write-Host "  1. Install manually from the app's official website" -ForegroundColor Gray
    Write-Host "  2. Use Microsoft Store if available" -ForegroundColor Gray
    Write-Host "  3. Run as admin and install system-wide" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "Setup complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor White
