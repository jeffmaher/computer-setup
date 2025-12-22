#Requires -RunAsAdministrator
# Disable Web Search and Widgets Script
# To Run: PowerShell -ExecutionPolicy Bypass -File .\disable_web_search.ps1
#
# This script disables web search in Start Menu and disables Windows Widgets
# to improve performance and privacy

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Disable Web Search & Widgets" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "This script will:" -ForegroundColor Yellow
Write-Host "  1. Disable web search in Start Menu" -ForegroundColor Gray
Write-Host "  2. Prevent Bing search results in Start Menu" -ForegroundColor Gray
Write-Host "  3. Disable web results over metered connections" -ForegroundColor Gray
Write-Host "  4. Disable Windows Widgets" -ForegroundColor Gray
Write-Host "  5. Configure registry settings for search" -ForegroundColor Gray
Write-Host ""
Write-Host "Benefits:" -ForegroundColor Cyan
Write-Host "  - Faster Start Menu search (local only)" -ForegroundColor Gray
Write-Host "  - No Bing web results cluttering search" -ForegroundColor Gray
Write-Host "  - Reduced network usage" -ForegroundColor Gray
Write-Host "  - Better privacy (no search queries sent to Microsoft)" -ForegroundColor Gray
Write-Host ""

$confirm = Read-Host "Do you want to continue? (y/n)"
if ($confirm -ne "y") {
    Write-Host "Configuration cancelled." -ForegroundColor Yellow
    exit
}

Write-Host ""
Write-Host "Starting configuration..." -ForegroundColor Green
Write-Host ""

# ============================================================================
# Step 1: Configure Group Policy Settings
# ============================================================================

Write-Host "========================================" -ForegroundColor White
Write-Host "Step 1: Configuring Group Policy" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor White
Write-Host ""

# Group Policy registry paths
$searchPolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
$widgetsPolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Dsh"

# Create registry paths if they don't exist
if (!(Test-Path $searchPolicyPath)) {
    Write-Host "Creating Search policy registry path..." -ForegroundColor Cyan
    New-Item -Path $searchPolicyPath -Force | Out-Null
}

if (!(Test-Path $widgetsPolicyPath)) {
    Write-Host "Creating Widgets policy registry path..." -ForegroundColor Cyan
    New-Item -Path $widgetsPolicyPath -Force | Out-Null
}

# Search Policy Settings
Write-Host "Configuring Search policies..." -ForegroundColor Cyan

# 1. Do not allow web search
Write-Host "  Setting: Do not allow web search" -ForegroundColor Gray
try {
    Set-ItemProperty -Path $searchPolicyPath -Name "DisableWebSearch" -Value 1 -Type DWord -Force
    Write-Host "  [OK] Web search disabled" -ForegroundColor Green
} catch {
    Write-Host "  [FAILED] Could not disable web search: $_" -ForegroundColor Red
}

# 2. Don't search the web or display web results in Search
Write-Host "  Setting: Don't search web or display web results" -ForegroundColor Gray
try {
    Set-ItemProperty -Path $searchPolicyPath -Name "ConnectedSearchUseWeb" -Value 0 -Type DWord -Force
    Write-Host "  [OK] Web results in Search disabled" -ForegroundColor Green
} catch {
    Write-Host "  [FAILED] Could not disable web results: $_" -ForegroundColor Red
}

# 3. Don't search the web or display web results over metered connections
Write-Host "  Setting: Don't search web over metered connections" -ForegroundColor Gray
try {
    Set-ItemProperty -Path $searchPolicyPath -Name "ConnectedSearchUseWebOverMeteredConnections" -Value 0 -Type DWord -Force
    Write-Host "  [OK] Web search over metered connections disabled" -ForegroundColor Green
} catch {
    Write-Host "  [FAILED] Could not disable web search over metered: $_" -ForegroundColor Red
}

# Widgets Policy Setting
Write-Host ""
Write-Host "Configuring Widgets policy..." -ForegroundColor Cyan

# 4. Disable Widgets
Write-Host "  Setting: Allow widgets - Disabled" -ForegroundColor Gray
try {
    Set-ItemProperty -Path $widgetsPolicyPath -Name "AllowNewsAndInterests" -Value 0 -Type DWord -Force
    Write-Host "  [OK] Widgets disabled" -ForegroundColor Green
} catch {
    Write-Host "  [FAILED] Could not disable Widgets: $_" -ForegroundColor Red
}

# ============================================================================
# Step 2: Configure User Registry Settings
# ============================================================================

Write-Host ""
Write-Host "========================================" -ForegroundColor White
Write-Host "Step 2: Configuring User Settings" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor White
Write-Host ""

$userSearchPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"

# Create path if it doesn't exist
if (!(Test-Path $userSearchPath)) {
    Write-Host "Creating user Search registry path..." -ForegroundColor Cyan
    New-Item -Path $userSearchPath -Force | Out-Null
}

# 5. Disable Bing Search
Write-Host "Disabling Bing search integration..." -ForegroundColor Cyan
try {
    Set-ItemProperty -Path $userSearchPath -Name "BingSearchEnabled" -Value 0 -Type DWord -Force
    Write-Host "[OK] Bing search disabled" -ForegroundColor Green
} catch {
    Write-Host "[FAILED] Could not disable Bing search: $_" -ForegroundColor Red
}

# Additional helpful settings
Write-Host ""
Write-Host "Applying additional search optimizations..." -ForegroundColor Cyan

# Disable Cortana web search
try {
    Set-ItemProperty -Path $userSearchPath -Name "CortanaConsent" -Value 0 -Type DWord -Force
    Write-Host "[OK] Cortana web search disabled" -ForegroundColor Green
} catch {
    Write-Host "[WARNING] Could not disable Cortana web search" -ForegroundColor Yellow
}

# Disable search highlights
try {
    Set-ItemProperty -Path $userSearchPath -Name "SearchboxTaskbarMode" -Value 0 -Type DWord -Force
    Write-Host "[OK] Search highlights disabled" -ForegroundColor Green
} catch {
    Write-Host "[WARNING] Could not disable search highlights" -ForegroundColor Yellow
}

# ============================================================================
# Step 3: Restart Windows Explorer
# ============================================================================

Write-Host ""
Write-Host "========================================" -ForegroundColor White
Write-Host "Step 3: Applying Changes" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor White
Write-Host ""

Write-Host "Restarting Windows Explorer to apply changes..." -ForegroundColor Cyan
try {
    Stop-Process -Name explorer -Force -ErrorAction Stop
    Start-Sleep -Seconds 2
    Write-Host "[OK] Windows Explorer restarted" -ForegroundColor Green
} catch {
    Write-Host "[WARNING] Could not restart Explorer automatically" -ForegroundColor Yellow
    Write-Host "You may need to sign out and back in for all changes to take effect" -ForegroundColor Yellow
}

# ============================================================================
# Step 4: Verify Settings
# ============================================================================

Write-Host ""
Write-Host "========================================" -ForegroundColor White
Write-Host "Verifying Configuration" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor White
Write-Host ""

$allGood = $true

# Check Search policies
Write-Host "Checking Search policies..." -ForegroundColor Cyan
$webSearchDisabled = Get-ItemProperty -Path $searchPolicyPath -Name "DisableWebSearch" -ErrorAction SilentlyContinue
$webResultsDisabled = Get-ItemProperty -Path $searchPolicyPath -Name "ConnectedSearchUseWeb" -ErrorAction SilentlyContinue
$meteredDisabled = Get-ItemProperty -Path $searchPolicyPath -Name "ConnectedSearchUseWebOverMeteredConnections" -ErrorAction SilentlyContinue

if ($webSearchDisabled.DisableWebSearch -eq 1) {
    Write-Host "  [OK] Web search is disabled" -ForegroundColor Green
} else {
    Write-Host "  [FAILED] Web search may not be disabled" -ForegroundColor Red
    $allGood = $false
}

if ($webResultsDisabled.ConnectedSearchUseWeb -eq 0) {
    Write-Host "  [OK] Web results are disabled" -ForegroundColor Green
} else {
    Write-Host "  [FAILED] Web results may not be disabled" -ForegroundColor Red
    $allGood = $false
}

# Check Widgets policy
Write-Host ""
Write-Host "Checking Widgets policy..." -ForegroundColor Cyan
$widgetsDisabled = Get-ItemProperty -Path $widgetsPolicyPath -Name "AllowNewsAndInterests" -ErrorAction SilentlyContinue

if ($widgetsDisabled.AllowNewsAndInterests -eq 0) {
    Write-Host "  [OK] Widgets are disabled" -ForegroundColor Green
} else {
    Write-Host "  [FAILED] Widgets may not be disabled" -ForegroundColor Red
    $allGood = $false
}

# Check user settings
Write-Host ""
Write-Host "Checking user settings..." -ForegroundColor Cyan
$bingDisabled = Get-ItemProperty -Path $userSearchPath -Name "BingSearchEnabled" -ErrorAction SilentlyContinue

if ($bingDisabled.BingSearchEnabled -eq 0) {
    Write-Host "  [OK] Bing search is disabled" -ForegroundColor Green
} else {
    Write-Host "  [FAILED] Bing search may not be disabled" -ForegroundColor Red
    $allGood = $false
}

# ============================================================================
# Summary
# ============================================================================

Write-Host ""
Write-Host "========================================" -ForegroundColor White
if ($allGood) {
    Write-Host "Configuration Successful!" -ForegroundColor Green
} else {
    Write-Host "Configuration Completed with Warnings" -ForegroundColor Yellow
}
Write-Host "========================================" -ForegroundColor White
Write-Host ""

Write-Host "Changes applied:" -ForegroundColor Cyan
Write-Host "  [OK] Web search disabled in Start Menu" -ForegroundColor Gray
Write-Host "  [OK] Bing search results disabled" -ForegroundColor Gray
Write-Host "  [OK] Web search over metered connections disabled" -ForegroundColor Gray
Write-Host "  [OK] Windows Widgets disabled" -ForegroundColor Gray
Write-Host "  [OK] Additional search optimizations applied" -ForegroundColor Gray
Write-Host ""

Write-Host "What this means:" -ForegroundColor Yellow
Write-Host "  - Start Menu search will only show local apps and files" -ForegroundColor Gray
Write-Host "  - No Bing web results in search" -ForegroundColor Gray
Write-Host "  - No web queries sent to Microsoft" -ForegroundColor Gray
Write-Host "  - Faster search performance" -ForegroundColor Gray
Write-Host "  - Reduced network usage" -ForegroundColor Gray
Write-Host "  - Widgets panel removed from taskbar" -ForegroundColor Gray
Write-Host ""

Write-Host "Testing the changes:" -ForegroundColor Cyan
Write-Host "  1. Click Start Menu and type something" -ForegroundColor Gray
Write-Host "  2. You should only see local apps and files" -ForegroundColor Gray
Write-Host "  3. No web results or 'Search the web' suggestions" -ForegroundColor Gray
Write-Host "  4. Widgets icon should be gone from taskbar" -ForegroundColor Gray
Write-Host ""

if (!$allGood) {
    Write-Host "Note: Some settings may require a sign out/sign in to fully apply." -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor White
Write-Host "Configuration complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor White
