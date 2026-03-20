# Battery Debug Script for Framework Laptop 13 AMD
# Generates battery report and energy efficiency report for troubleshooting
#
# REQUIRES: Run as Administrator (right-click PowerShell -> Run as Administrator)
#
# HOW TO RUN:
#   1. Right-click Windows Terminal or PowerShell -> "Run as Administrator"
#   2. Navigate to the folder containing this script:
#        cd C:\path\to\folder
#   3. Run:
#        PowerShell -ExecutionPolicy Bypass -File .\battery-debug.ps1
#
# OUTPUT:
#   Creates a folder on your Desktop called "battery-debug-YYYY-MM-DD" containing:
#     - battery-report.html    (charge history, usage, capacity trends)
#     - energy-report.html     (60-second system trace for power inefficiencies)
#     - summary.txt            (quick text summary of key stats)
#
#   Upload the entire folder (or zip it) to share with Claude for analysis.

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Battery Debug Script - Framework 13 AMD" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# --- Check for admin privileges ---
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "[ERROR] This script must be run as Administrator." -ForegroundColor Red
    Write-Host ""
    Write-Host "How to fix:" -ForegroundColor Yellow
    Write-Host "  1. Right-click Windows Terminal or PowerShell" -ForegroundColor Yellow
    Write-Host "  2. Select 'Run as Administrator'" -ForegroundColor Yellow
    Write-Host "  3. Run this script again" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

# --- Create output folder on Desktop ---
$dateStamp = Get-Date -Format "yyyy-MM-dd"
$outputDir = Join-Path ([Environment]::GetFolderPath("Desktop")) "battery-debug-$dateStamp"

if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
}

Write-Host "Output folder: $outputDir" -ForegroundColor Gray
Write-Host ""

# --- Generate battery report ---
Write-Host "[1/3] Generating battery report..." -ForegroundColor Yellow
$batteryReportPath = Join-Path $outputDir "battery-report.html"
powercfg /batteryreport /output "$batteryReportPath" 2>&1 | Out-Null

if (Test-Path $batteryReportPath) {
    Write-Host "      Done: battery-report.html" -ForegroundColor Green
} else {
    Write-Host "      WARNING: Battery report failed. Are you on a laptop with a battery?" -ForegroundColor Red
}
Write-Host ""

# --- Generate energy report (takes 60 seconds) ---
Write-Host "[2/3] Running energy trace (60 seconds)..." -ForegroundColor Yellow
Write-Host "      Please don't sleep or close the lid during this trace." -ForegroundColor Gray

$energyReportPath = Join-Path $outputDir "energy-report.html"
powercfg /energy /output "$energyReportPath" 2>&1 | Out-Null

if (Test-Path $energyReportPath) {
    Write-Host "      Done: energy-report.html" -ForegroundColor Green
} else {
    Write-Host "      WARNING: Energy report failed." -ForegroundColor Red
}
Write-Host ""

# --- Generate text summary ---
Write-Host "[3/3] Collecting summary info..." -ForegroundColor Yellow

$summaryPath = Join-Path $outputDir "summary.txt"
$summary = @()

$summary += "Battery Debug Summary - $(Get-Date)"
$summary += "=========================================="
$summary += ""

# System info
$cs = Get-CimInstance Win32_ComputerSystem
$os = Get-CimInstance Win32_OperatingSystem
$bios = Get-CimInstance Win32_BIOS
$summary += "System: $($cs.Manufacturer) $($cs.Model)"
$summary += "OS: $($os.Caption) $($os.Version)"
$summary += "BIOS: $($bios.SMBIOSBIOSVersion)"
$summary += ""

# Battery info
$battery = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue
if ($battery) {
    $summary += "=== BATTERY STATUS ==="
    $summary += "  Status: $($battery.Status)"
    $summary += "  Charge: $($battery.EstimatedChargeRemaining)%"
    $summary += "  Estimated Runtime: $($battery.EstimatedRunTime) minutes"
    $summary += ""
}

# Detailed battery info from WMI
$batteryInfo = Get-CimInstance -Namespace root\WMI -ClassName BatteryFullChargedCapacity -ErrorAction SilentlyContinue
$batteryDesign = Get-CimInstance -Namespace root\WMI -ClassName BatteryStaticData -ErrorAction SilentlyContinue
if ($batteryInfo -and $batteryDesign) {
    $fullCharge = $batteryInfo.FullChargedCapacity
    $designCap = $batteryDesign.DesignedCapacity
    if ($designCap -gt 0) {
        $health = [math]::Round(($fullCharge / $designCap) * 100, 1)
        $summary += "=== BATTERY HEALTH ==="
        $summary += "  Design Capacity: $designCap mWh"
        $summary += "  Full Charge Capacity: $fullCharge mWh"
        $summary += "  Health: $health%"
        $summary += ""
    }
}

# Power configuration
$summary += "=== POWER SETTINGS ==="
$activeScheme = powercfg /getactivescheme
$summary += "  Active Scheme: $activeScheme"
$summary += ""

# Energy saver status
$summary += "=== ENERGY SAVER ==="
try {
    $energySaver = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power" -Name "EnergySaverPolicy" -ErrorAction SilentlyContinue
    if ($energySaver) {
        $summary += "  EnergySaverPolicy: $($energySaver.EnergySaverPolicy)"
    }
} catch {
    $summary += "  (Could not read energy saver policy)"
}
$summary += ""

# Current power draw estimate via remaining time
$summary += "=== DISCHARGE ESTIMATE ==="
if ($battery -and $battery.EstimatedChargeRemaining -and $battery.EstimatedRunTime) {
    if ($battery.EstimatedRunTime -gt 0 -and $battery.EstimatedRunTime -lt 71582788) {
        $summary += "  Current charge: $($battery.EstimatedChargeRemaining)%"
        $summary += "  Estimated remaining: $($battery.EstimatedRunTime) minutes"
        $summary += "  (For accurate drain rate, check battery-report.html)"
    } else {
        $summary += "  Plugged in or estimate unavailable"
    }
} else {
    $summary += "  Battery info unavailable"
}
$summary += ""

# Processes using most CPU (top power consumers)
$summary += "=== TOP CPU CONSUMERS (snapshot) ==="
$topProcs = Get-Process | Sort-Object CPU -Descending | Select-Object -First 15 | Format-Table Name, CPU, WorkingSet64 -AutoSize | Out-String
$summary += $topProcs

# Wake timers
$summary += "=== ACTIVE WAKE TIMERS ==="
$wakeTimers = powercfg /waketimers 2>&1 | Out-String
$summary += $wakeTimers

# Devices that can wake the computer
$summary += "=== DEVICES THAT CAN WAKE COMPUTER ==="
$wakeDevices = powercfg /devicequery wake_armed 2>&1 | Out-String
$summary += $wakeDevices

$summary | Out-File -FilePath $summaryPath -Encoding UTF8
Write-Host "      Done: summary.txt" -ForegroundColor Green
Write-Host ""

# --- Final output ---
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  All done!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Files saved to:" -ForegroundColor White
Write-Host "  $outputDir" -ForegroundColor Yellow
Write-Host ""
Write-Host "Contents:" -ForegroundColor White
Write-Host "  - battery-report.html  (charge history & capacity trends)" -ForegroundColor Gray
Write-Host "  - energy-report.html   (power inefficiencies found in 60s trace)" -ForegroundColor Gray
Write-Host "  - summary.txt          (quick stats & top CPU consumers)" -ForegroundColor Gray
Write-Host ""
Write-Host "To share: zip the folder and upload it to Claude." -ForegroundColor Cyan
Write-Host ""

# Open the folder
explorer $outputDir
