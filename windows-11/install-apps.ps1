# To Run, issue this in an admin launched Power Shell terminal
# PowerShell -ExecutionPolicy Bypass -File .\setup_apps.ps1

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

# WinGet manageable bloatware to remove
$wingetBloatware = @(
    @{ id = "Microsoft.OneDrive"; name = "Microsoft OneDrive" },
    @{ id = "Microsoft.Teams"; name = "Microsoft Teams" }
)

# Array of applications to install
$apps = @(
    @{ id = "Mozilla.Firefox"; name = "Firefox" },
    @{ id = "Microsoft.VisualStudioCode"; name = "VS Code" },
    @{ id = "TheDocumentFoundation.LibreOffice"; name = "LibreOffice" },
    @{ id = "OpenWhisperSystems.Signal"; name = "Signal" },
    @{ id = "OpenWhisperSystems.Signal.Beta"; name = "Signal Beta" },
    @{ id = "SlackTechnologies.Slack"; name = "Slack" },
    @{ id = "Google.Chrome"; name = "Google Chrome" },
    @{ id = "AgileBits.1Password"; name = "1Password" },
    @{ id = "Doist.Todoist"; name = "Todoist" },
    #@{ id = "Foxit.PhantomPDF"; name = "Foxit PhantomPDF"; version = "13.1.7.23637" },
    #@{ id = "TechSmith.Snagit.2024"; name = "Snagit 2024" },
    #@{ id = "TechSmith.Camtasia"; name = "Camtasia 2024", version = "24.1.5.6542" },
    @{ id = "Docker.DockerDesktop"; name = "Docker Desktop" },
    @{ id = "Zoom.Zoom"; name = "Zoom" },
    #@{ id = "SublimeHQ.SublimeText.4"; name = "Sublime Text" },
    #@{ id = "SublimeHQ.SublimeMerge"; name = "Sublime Merge" },
    @{ id = "VideoLAN.VLC"; name = "VLC Media Player"},
    @{ id = "Figma.Figma"; name = "Figma" },
    @{ id = "Microsoft.PowerToys"; name = "Microsoft PowerToys" }
)

# Remove Windows Store apps first
Write-Host "========================================" -ForegroundColor White
Write-Host "Removing Windows Store bloatware..." -ForegroundColor Red
Write-Host "========================================" -ForegroundColor White

foreach ($appName in $storeAppsToRemove) {
    Write-Host ""
    Write-Host "Checking for $appName..." -ForegroundColor Cyan
    $packages = Get-AppxPackage -Name "*$appName*" -AllUsers -ErrorAction SilentlyContinue
    if ($packages) {
        Write-Host "  Found $($packages.Count) package(s) matching $appName" -ForegroundColor Yellow
        foreach ($package in $packages) {
            Write-Host "  Attempting to remove: $($package.Name)" -ForegroundColor Red
            Write-Host "    Package Full Name: $($package.PackageFullName)" -ForegroundColor Gray
            try {
                Remove-AppxPackage -Package $package.PackageFullName -AllUsers -ErrorAction Stop
                Write-Host "    SUCCESS: $($package.Name) removed successfully" -ForegroundColor Green
            } catch {
                Write-Host "    FAILED: Could not remove $($package.Name)" -ForegroundColor Red
                Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "  NOT FOUND: $appName not installed - skipping" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor White

# Remove WinGet manageable bloatware
Write-Host "Removing WinGet bloatware..." -ForegroundColor Red
Write-Host "========================================" -ForegroundColor White

foreach ($app in $wingetBloatware) {
    Write-Host ""
    Write-Host "Checking for $($app.name) ($($app.id))..." -ForegroundColor Cyan
    Write-Host "  Running: winget list --id $($app.id)" -ForegroundColor Gray
    $installed = winget list --id $app.id --accept-source-agreements 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  FOUND: $($app.name) is installed" -ForegroundColor Yellow
        Write-Host "  Attempting removal with: winget uninstall $($app.id)" -ForegroundColor Red
        $uninstallResult = winget uninstall $app.id --silent --accept-source-agreements 2>&1
        Write-Host "  Uninstall output: $uninstallResult" -ForegroundColor Gray
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  SUCCESS: $($app.name) removed successfully" -ForegroundColor Green
        } else {
            Write-Host "  FAILED: Could not remove $($app.name)" -ForegroundColor Red
            Write-Host "  Exit code: $LASTEXITCODE" -ForegroundColor Red
        }
    } else {
        Write-Host "  NOT FOUND: $($app.name) not installed - skipping" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor White
Write-Host "Installing applications..." -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor White

# Install apps
foreach ($app in $apps) {
    Write-Host ""
    Write-Host "Checking $($app.name) ($($app.id))..." -ForegroundColor Cyan
    
    Write-Host "  Running: winget list --id $($app.id)" -ForegroundColor Gray
    $installed = winget list --id $app.id --accept-source-agreements 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ALREADY INSTALLED: $($app.name) is already installed - skipping" -ForegroundColor Green
        continue
    }
    
    Write-Host "  NOT FOUND: Installing $($app.name)..." -ForegroundColor Yellow
    
    # Build the install command
    $installCmd = "winget install $($app.id) --silent --accept-package-agreements --accept-source-agreements"
    
    # Add version if specified
    if ($app.version) {
        $installCmd += " --version `"$($app.version)`""
        Write-Host "    Installing specific version: $($app.version)" -ForegroundColor Cyan
    }
    
    Write-Host "  Running: $installCmd" -ForegroundColor Gray
    
    # Execute the command and capture output
    $installResult = Invoke-Expression "$installCmd 2>&1"
    Write-Host "  Install output: $installResult" -ForegroundColor Gray
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  SUCCESS: $($app.name) installed successfully" -ForegroundColor Green
    } else {
        Write-Host "  FAILED: Failed to install $($app.name)" -ForegroundColor Red
        Write-Host "  Exit code: $LASTEXITCODE" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor White
Write-Host "Setup complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor White
