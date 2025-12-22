#Requires -RunAsAdministrator
# UAC Configuration Script - Require Admin Password
# To Run: PowerShell -ExecutionPolicy Bypass -File .\configure_uac.ps1
#
# This script configures User Account Control (UAC) to always prompt for
# admin credentials on the secure desktop whenever software wants to make
# major system changes.

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "UAC Configuration - Require Admin Password" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "This script will configure UAC to:" -ForegroundColor Yellow
Write-Host "  - Always prompt for admin credentials" -ForegroundColor Gray
Write-Host "  - Display prompts on secure desktop (prevents spoofing)" -ForegroundColor Gray
Write-Host "  - Apply to both administrators and standard users" -ForegroundColor Gray
Write-Host ""
Write-Host "This enhances security by requiring explicit approval for system changes." -ForegroundColor Yellow
Write-Host ""

$confirm = Read-Host "Do you want to continue? (y/n)"
if ($confirm -ne "y") {
    Write-Host "Cancelled by user." -ForegroundColor Yellow
    exit
}

Write-Host ""
Write-Host "Configuring UAC settings..." -ForegroundColor Green
Write-Host ""

# Registry path for UAC settings
$uacPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"

try {
    # Setting 1: Behavior of the elevation prompt for administrators in Admin Approval Mode
    # Value: 1 = Prompt for credentials on the secure desktop
    Write-Host "Setting: Elevation prompt for administrators..." -ForegroundColor Cyan
    Set-ItemProperty -Path $uacPath -Name "ConsentPromptBehaviorAdmin" -Value 1 -Type DWord -Force
    Write-Host "  [OK] Administrators will be prompted for credentials" -ForegroundColor Green
    
    # Setting 2: Behavior of the elevation prompt for standard users
    # Value: 1 = Prompt for credentials
    Write-Host "Setting: Elevation prompt for standard users..." -ForegroundColor Cyan
    Set-ItemProperty -Path $uacPath -Name "ConsentPromptBehaviorUser" -Value 1 -Type DWord -Force
    Write-Host "  [OK] Standard users will be prompted for credentials" -ForegroundColor Green
    
    # Setting 3: Switch to secure desktop when prompting for elevation
    # Value: 1 = Enabled (recommended for security)
    Write-Host "Setting: Secure desktop for prompts..." -ForegroundColor Cyan
    Set-ItemProperty -Path $uacPath -Name "PromptOnSecureDesktop" -Value 1 -Type DWord -Force
    Write-Host "  [OK] Prompts will appear on secure desktop" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "UAC Configuration Complete!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "Changes applied:" -ForegroundColor Cyan
    Write-Host "  [OK] Admin elevation prompt: Prompt for credentials on secure desktop" -ForegroundColor Gray
    Write-Host "  [OK] Standard user elevation prompt: Prompt for credentials" -ForegroundColor Gray
    Write-Host "  [OK] Secure desktop: Enabled" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "What this means:" -ForegroundColor Yellow
    Write-Host "  - You'll be asked for your admin password when making system changes" -ForegroundColor Gray
    Write-Host "  - Prompts appear on a dimmed, secure screen (harder to fake)" -ForegroundColor Gray
    Write-Host "  - This prevents unauthorized software from making changes" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "Note: Changes take effect immediately. No restart required." -ForegroundColor Cyan
    Write-Host ""
    
} catch {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "Error Configuring UAC" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "An error occurred while configuring UAC settings:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "Please ensure:" -ForegroundColor Yellow
    Write-Host "  - You're running this script as Administrator" -ForegroundColor Gray
    Write-Host "  - You're on Windows 11 Pro (Home may have limited UAC options)" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

# Verify settings
Write-Host "Verifying configuration..." -ForegroundColor Cyan
Write-Host ""

$adminBehavior = Get-ItemProperty -Path $uacPath -Name "ConsentPromptBehaviorAdmin" -ErrorAction SilentlyContinue
$userBehavior = Get-ItemProperty -Path $uacPath -Name "ConsentPromptBehaviorUser" -ErrorAction SilentlyContinue
$secureDesktop = Get-ItemProperty -Path $uacPath -Name "PromptOnSecureDesktop" -ErrorAction SilentlyContinue

if ($adminBehavior.ConsentPromptBehaviorAdmin -eq 1 -and 
    $userBehavior.ConsentPromptBehaviorUser -eq 1 -and 
    $secureDesktop.PromptOnSecureDesktop -eq 1) {
    Write-Host "[OK] Verification successful! All UAC settings are configured correctly." -ForegroundColor Green
} else {
    Write-Host "[WARNING] Some settings may not have been applied correctly." -ForegroundColor Yellow
    Write-Host "Please verify manually in Local Security Policy." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor White
Write-Host "Configuration complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor White
