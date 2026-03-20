# Windows Sleep/Wake Diagnostic Script
# Collects power, display, and wake information for troubleshooting
#
# HOW TO RUN:
# 1. Open PowerShell (Start Menu -> type "PowerShell" -> click Windows PowerShell)
# 2. Navigate to the folder containing this script:
#      cd C:\path\to\folder
# 3. Run with execution policy bypass (scripts are disabled by default):
#      PowerShell -ExecutionPolicy Bypass -File .\wake-debug.ps1
#
# TO SAVE OUTPUT FOR SHARING:
#      PowerShell -ExecutionPolicy Bypass -File .\wake-debug.ps1 | Out-File wake-debug-output.txt
#
# FOR FULL DETAILS: Run PowerShell as Administrator (right-click -> Run as Administrator)

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Windows Sleep/Wake Diagnostics" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "[INFO] Running as standard user. Run as Administrator for full details." -ForegroundColor Yellow
    Write-Host ""
}

# System info
Write-Host "========================================" -ForegroundColor White
Write-Host "System Information" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor White
$cs = Get-CimInstance Win32_ComputerSystem
$os = Get-CimInstance Win32_OperatingSystem
$bios = Get-CimInstance Win32_BIOS
Write-Host "Computer: $($cs.Manufacturer) $($cs.Model)"
Write-Host "OS: $($os.Caption) $($os.Version)"
Write-Host "BIOS: $($bios.SMBIOSBIOSVersion)"
Write-Host ""

# Current power scheme
Write-Host "========================================" -ForegroundColor White
Write-Host "Power Configuration" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor White
Write-Host ""
Write-Host "Active Power Scheme:" -ForegroundColor Yellow
powercfg /getactivescheme
Write-Host ""

# Sleep settings
Write-Host "Sleep Timeouts:" -ForegroundColor Yellow
$scheme = (powercfg /getactivescheme) -replace '.*: ([-a-f0-9]+).*','$1'
Write-Host "  AC (plugged in):"
$acMonitor = powercfg /query $scheme SUB_VIDEO VIDEOIDLE 2>$null | Select-String "Current AC Power Setting Index" | ForEach-Object { ($_ -split ": ")[1] }
$acSleep = powercfg /query $scheme SUB_SLEEP STANDBYIDLE 2>$null | Select-String "Current AC Power Setting Index" | ForEach-Object { ($_ -split ": ")[1] }
Write-Host "    Monitor off: $([int]$acMonitor / 60) minutes"
Write-Host "    Sleep after: $([int]$acSleep / 60) minutes"
Write-Host "  DC (battery):"
$dcMonitor = powercfg /query $scheme SUB_VIDEO VIDEOIDLE 2>$null | Select-String "Current DC Power Setting Index" | ForEach-Object { ($_ -split ": ")[1] }
$dcSleep = powercfg /query $scheme SUB_SLEEP STANDBYIDLE 2>$null | Select-String "Current DC Power Setting Index" | ForEach-Object { ($_ -split ": ")[1] }
Write-Host "    Monitor off: $([int]$dcMonitor / 60) minutes"
Write-Host "    Sleep after: $([int]$dcSleep / 60) minutes"
Write-Host ""

# Modern Standby / S0 Low Power Idle
Write-Host "Sleep Type:" -ForegroundColor Yellow
$sleepStates = powercfg /availablesleepstates 2>&1
$sleepStates | ForEach-Object { Write-Host "  $_" }
Write-Host ""

# Last wake source
Write-Host "========================================" -ForegroundColor White
Write-Host "Last Wake Information" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor White
Write-Host ""
Write-Host "Last Wake Source:" -ForegroundColor Yellow
powercfg /lastwake
Write-Host ""

# Devices that can wake the computer
Write-Host "Devices That Can Wake Computer:" -ForegroundColor Yellow
powercfg /devicequery wake_armed
Write-Host ""

# Recent sleep/wake events from Event Log
Write-Host "========================================" -ForegroundColor White
Write-Host "Recent Sleep/Wake Events (Last 24 Hours)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor White
Write-Host ""

$yesterday = (Get-Date).AddHours(-24)

# Power-Troubleshooter events (sleep/wake)
Write-Host "Sleep/Wake Transitions:" -ForegroundColor Yellow
try {
    $powerEvents = Get-WinEvent -FilterHashtable @{
        LogName = 'System'
        ProviderName = 'Microsoft-Windows-Power-Troubleshooter'
        StartTime = $yesterday
    } -ErrorAction SilentlyContinue | Select-Object -First 20

    if ($powerEvents) {
        foreach ($event in $powerEvents) {
            $time = $event.TimeCreated.ToString("yyyy-MM-dd HH:mm:ss")
            Write-Host "  [$time] Wake from sleep" -ForegroundColor Green
            $msg = $event.Message
            if ($msg -match "Wake Source: (.+)") {
                Write-Host "    Source: $($Matches[1])" -ForegroundColor Gray
            }
        }
    } else {
        Write-Host "  No sleep/wake events in last 24 hours" -ForegroundColor Gray
    }
} catch {
    Write-Host "  Could not read power events (may need admin)" -ForegroundColor Red
}
Write-Host ""

# Kernel-Power events
Write-Host "Power State Changes:" -ForegroundColor Yellow
try {
    $kernelPower = Get-WinEvent -FilterHashtable @{
        LogName = 'System'
        ProviderName = 'Microsoft-Windows-Kernel-Power'
        StartTime = $yesterday
        Id = 42, 107, 109, 506, 507
    } -ErrorAction SilentlyContinue | Select-Object -First 20

    if ($kernelPower) {
        foreach ($event in $kernelPower) {
            $time = $event.TimeCreated.ToString("yyyy-MM-dd HH:mm:ss")
            $desc = switch ($event.Id) {
                42 { "Entering sleep" }
                107 { "Resume from hibernate" }
                109 { "Resume from sleep" }
                506 { "Connected Standby entry" }
                507 { "Connected Standby exit" }
                default { "Power event $($event.Id)" }
            }
            Write-Host "  [$time] $desc" -ForegroundColor Gray
        }
    } else {
        Write-Host "  No power state events in last 24 hours" -ForegroundColor Gray
    }
} catch {
    Write-Host "  Could not read kernel power events (may need admin)" -ForegroundColor Red
}
Write-Host ""

# Critical errors
Write-Host "========================================" -ForegroundColor White
Write-Host "Critical Errors (Last 24 Hours)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor White
Write-Host ""

try {
    $criticalErrors = Get-WinEvent -FilterHashtable @{
        LogName = 'System'
        Level = 1,2
        StartTime = $yesterday
    } -ErrorAction SilentlyContinue | Where-Object {
        $_.ProviderName -match 'Power|Display|ACPI|USB|Thunderbolt|PCI|AMD|GPU|Video|Kernel'
    } | Select-Object -First 15

    if ($criticalErrors) {
        foreach ($event in $criticalErrors) {
            $time = $event.TimeCreated.ToString("yyyy-MM-dd HH:mm:ss")
            $level = if ($event.Level -eq 1) { "CRITICAL" } else { "ERROR" }
            Write-Host "  [$time] [$level] $($event.ProviderName)" -ForegroundColor Red
            Write-Host "    $($event.Message.Split("`n")[0])" -ForegroundColor Gray
        }
    } else {
        Write-Host "  No critical power/display errors in last 24 hours" -ForegroundColor Green
    }
} catch {
    Write-Host "  Could not read error events (may need admin)" -ForegroundColor Red
}
Write-Host ""

# Display adapters
Write-Host "========================================" -ForegroundColor White
Write-Host "Display Configuration" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor White
Write-Host ""
Write-Host "Display Adapters:" -ForegroundColor Yellow
Get-CimInstance Win32_VideoController | ForEach-Object {
    Write-Host "  $($_.Name)"
    Write-Host "    Driver: $($_.DriverVersion)" -ForegroundColor Gray
    Write-Host "    Status: $($_.Status)" -ForegroundColor Gray
}
Write-Host ""

Write-Host "Connected Monitors:" -ForegroundColor Yellow
Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorID -ErrorAction SilentlyContinue | ForEach-Object {
    $name = [System.Text.Encoding]::ASCII.GetString($_.UserFriendlyName -ne 0)
    $serial = [System.Text.Encoding]::ASCII.GetString($_.SerialNumberID -ne 0)
    Write-Host "  $name (Serial: $serial)"
}
Write-Host ""

# Thunderbolt/USB-C
Write-Host "========================================" -ForegroundColor White
Write-Host "Thunderbolt / USB-C Status" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor White
Write-Host ""
$tbDevices = Get-PnpDevice | Where-Object { $_.FriendlyName -match 'Thunderbolt|USB4' -and $_.Status -eq 'OK' }
if ($tbDevices) {
    $tbDevices | ForEach-Object {
        Write-Host "  $($_.FriendlyName)" -ForegroundColor Green
    }
} else {
    Write-Host "  No active Thunderbolt devices detected" -ForegroundColor Gray
}
Write-Host ""

Write-Host "USB Hubs (Dock):" -ForegroundColor Yellow
Get-PnpDevice -Class USB | Where-Object { $_.FriendlyName -match 'Hub' -and $_.Status -eq 'OK' } | ForEach-Object {
    Write-Host "  $($_.FriendlyName)" -ForegroundColor Gray
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Green
Write-Host "Diagnostic Complete" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "To share results, copy the output above or run:" -ForegroundColor Yellow
Write-Host "  .\wake-debug.ps1 | Out-File wake-debug-output.txt" -ForegroundColor Cyan
Write-Host ""