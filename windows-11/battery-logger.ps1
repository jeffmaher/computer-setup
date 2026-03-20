# Battery Life Logger for Framework Laptop 13 AMD
# Logs battery percentage, power state, and estimated drain rate over time
# Designed to capture real-world battery life data for comparison purposes
#
# HOW TO RUN:
#   1. Open PowerShell (does NOT require Administrator)
#   2. Navigate to the folder containing this script:
#        cd C:\path\to\folder
#   3. Run:
#        PowerShell -ExecutionPolicy Bypass -File .\battery-logger.ps1
#
# HOW TO USE:
#   - Start the script when you unplug from power
#   - Use your laptop normally
#   - The script logs every 5 minutes in the background
#   - When you're done (plugging back in or shutting down), press Ctrl+C to stop
#   - The script saves a CSV log and a summary text file to your Desktop
#
# OUTPUT:
#   Creates files on your Desktop:
#     - battery-log-YYYY-MM-DD-HHMM.csv   (detailed time-series data)
#     - battery-log-YYYY-MM-DD-HHMM.txt   (human-readable summary)
#
#   Upload both files to Claude for analysis.

param(
    [int]$IntervalSeconds = 300  # Default: log every 5 minutes (300 seconds)
)

$dateStamp = Get-Date -Format "yyyy-MM-dd-HHmm"
$desktopPath = [Environment]::GetFolderPath("Desktop")
$csvPath = Join-Path $desktopPath "battery-log-$dateStamp.csv"
$summaryPath = Join-Path $desktopPath "battery-log-$dateStamp.txt"

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Battery Life Logger - Framework 13 AMD" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# --- Check for battery ---
$battery = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue
if (-not $battery) {
    Write-Host "[ERROR] No battery detected. Are you running this on a laptop?" -ForegroundColor Red
    exit 1
}

# --- System info header ---
$cs = Get-CimInstance Win32_ComputerSystem
$os = Get-CimInstance Win32_OperatingSystem
$bios = Get-CimInstance Win32_BIOS
Write-Host "System: $($cs.Manufacturer) $($cs.Model)" -ForegroundColor Gray
Write-Host "OS: $($os.Caption) $($os.Version)" -ForegroundColor Gray
Write-Host "BIOS: $($bios.SMBIOSBIOSVersion)" -ForegroundColor Gray
Write-Host ""

# --- Get initial state ---
$initialCharge = $battery.EstimatedChargeRemaining
$isPluggedIn = $battery.BatteryStatus -ge 2 -and $battery.BatteryStatus -ne 5

if ($isPluggedIn) {
    Write-Host "[WARNING] Laptop is currently plugged in." -ForegroundColor Yellow
    Write-Host "          For accurate battery life measurement, unplug before starting." -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "Starting battery: $initialCharge%" -ForegroundColor White
Write-Host "Logging every $IntervalSeconds seconds ($([math]::Round($IntervalSeconds/60, 1)) minutes)" -ForegroundColor White
Write-Host "Log file: $csvPath" -ForegroundColor Gray
Write-Host ""
Write-Host "Press Ctrl+C to stop logging and generate summary." -ForegroundColor Yellow
Write-Host ""
Write-Host "  Time          Battery   Status         Drain Rate" -ForegroundColor Cyan
Write-Host "  -----------   -------   -----------    ----------" -ForegroundColor Cyan

# --- Initialize CSV ---
"Timestamp,ElapsedMinutes,BatteryPercent,Status,EstimatedRuntimeMin,PowerScheme,ScreenBrightness" | Out-File -FilePath $csvPath -Encoding UTF8

# --- Logging state ---
$startTime = Get-Date
$lastPercent = $initialCharge
$lastTime = $startTime
$logEntries = @()

# --- Helper to get screen brightness ---
function Get-Brightness {
    try {
        $brightness = (Get-CimInstance -Namespace root/WMI -ClassName WmiMonitorBrightness -ErrorAction SilentlyContinue).CurrentBrightness
        return $brightness
    } catch {
        return "N/A"
    }
}

# --- Helper to get power scheme ---
function Get-PowerScheme {
    try {
        $scheme = powercfg /getactivescheme 2>$null
        if ($scheme -match "\((.+)\)") {
            return $Matches[1]
        }
        return "Unknown"
    } catch {
        return "Unknown"
    }
}

# --- Logging function ---
function Write-LogEntry {
    $now = Get-Date
    $bat = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue
    if (-not $bat) { return }

    $elapsed = ($now - $startTime).TotalMinutes
    $percent = $bat.EstimatedChargeRemaining
    $runtime = $bat.EstimatedRunTime
    $brightness = Get-Brightness
    $scheme = Get-PowerScheme

    # Determine status
    $statusCode = $bat.BatteryStatus
    switch ($statusCode) {
        1 { $status = "Discharging" }
        2 { $status = "AC Power" }
        3 { $status = "Charged" }
        4 { $status = "Low" }
        5 { $status = "Critical" }
        6 { $status = "Charging" }
        7 { $status = "Charging+High" }
        8 { $status = "Charging+Low" }
        9 { $status = "Charging+Crit" }
        default { $status = "Unknown ($statusCode)" }
    }

    # Calculate drain rate
    $timeDiff = ($now - $lastTime).TotalHours
    $drainRate = ""
    if ($timeDiff -gt 0 -and $status -eq "Discharging") {
        $percentDiff = $lastPercent - $percent
        if ($percentDiff -gt 0) {
            $ratePerHour = [math]::Round($percentDiff / $timeDiff, 1)
            $estimatedTotal = [math]::Round(100 / $ratePerHour, 1)
            $drainRate = "-$ratePerHour%/hr (~$($estimatedTotal)h total)"
        } elseif ($percentDiff -eq 0) {
            $drainRate = "(stable)"
        }
    }

    # Runtime display
    $runtimeDisplay = if ($runtime -and $runtime -lt 71582788) { "${runtime}m" } else { "N/A" }

    # Console output
    $timeStr = $now.ToString("HH:mm:ss")
    $elapsedStr = "$([math]::Round($elapsed, 0))m"
    Write-Host "  $timeStr ($($elapsedStr.PadLeft(5)))   $($percent.ToString().PadLeft(4))%   $($status.PadRight(13))  $drainRate"

    # CSV output
    "$($now.ToString('yyyy-MM-dd HH:mm:ss')),$([math]::Round($elapsed, 1)),$percent,$status,$runtimeDisplay,$scheme,$brightness" | Out-File -FilePath $csvPath -Append -Encoding UTF8

    # Track for summary
    $script:logEntries += [PSCustomObject]@{
        Time = $now
        Elapsed = $elapsed
        Percent = $percent
        Status = $status
    }

    $script:lastPercent = $percent
    $script:lastTime = $now
}

# --- Generate summary ---
function Write-Summary {
    $endTime = Get-Date
    $totalMinutes = ($endTime - $startTime).TotalMinutes
    $totalHours = [math]::Round($totalMinutes / 60, 2)

    $endBattery = (Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue).EstimatedChargeRemaining
    $percentUsed = $initialCharge - $endBattery

    $summary = @()
    $summary += "Battery Life Log Summary"
    $summary += "========================"
    $summary += "Date: $(Get-Date -Format 'yyyy-MM-dd')"
    $summary += "System: $($cs.Manufacturer) $($cs.Model)"
    $summary += "OS: $($os.Caption) $($os.Version)"
    $summary += "BIOS: $($bios.SMBIOSBIOSVersion)"
    $summary += ""
    $summary += "Session:"
    $summary += "  Start time:    $($startTime.ToString('HH:mm:ss'))"
    $summary += "  End time:      $($endTime.ToString('HH:mm:ss'))"
    $summary += "  Duration:      $totalHours hours ($([math]::Round($totalMinutes, 0)) minutes)"
    $summary += "  Start battery: $initialCharge%"
    $summary += "  End battery:   $endBattery%"
    $summary += "  Used:          $percentUsed%"
    $summary += ""

    if ($percentUsed -gt 0) {
        $drainPerHour = [math]::Round($percentUsed / ($totalMinutes / 60), 1)
        $projectedTotal = [math]::Round(100 / $drainPerHour, 1)
        $summary += "Drain rate:      $drainPerHour% per hour"
        $summary += "Projected full drain: ~$projectedTotal hours (100% to 0%)"
        $summary += ""
        $summary += "Note: 'Projected full drain' assumes consistent usage."
        $summary += "Real-world battery life will vary based on workload,"
        $summary += "screen brightness, WiFi usage, and power settings."
    } else {
        $summary += "No battery drain recorded (was the laptop plugged in?)"
    }

    $summary += ""
    $summary += "Detailed log: $csvPath"

    $summary | Out-File -FilePath $summaryPath -Encoding UTF8

    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "  Session Complete" -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""
    foreach ($line in $summary) {
        Write-Host "  $line"
    }
    Write-Host ""
    Write-Host "Files saved to Desktop:" -ForegroundColor White
    Write-Host "  $csvPath" -ForegroundColor Yellow
    Write-Host "  $summaryPath" -ForegroundColor Yellow
    Write-Host ""
}

# --- Main loop ---
try {
    # Log initial state immediately
    Write-LogEntry

    while ($true) {
        Start-Sleep -Seconds $IntervalSeconds
        Write-LogEntry

        # Auto-stop if battery hits critical
        $currentBat = (Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue).EstimatedChargeRemaining
        if ($currentBat -le 5) {
            Write-Host ""
            Write-Host "  [WARNING] Battery at $currentBat% - stopping to prevent shutdown." -ForegroundColor Red
            break
        }
    }
} finally {
    Write-Summary
}
