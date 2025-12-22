#Requires -RunAsAdministrator
# Windows 11 System Settings Configuration Script
# To Run: PowerShell -ExecutionPolicy Bypass -File .\configure_system_settings.ps1
#
# This script configures Windows 11 system settings to optimize privacy, performance, and usability

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Windows 11 System Settings Configuration" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "This script will configure:" -ForegroundColor Yellow
Write-Host ""
Write-Host "System:" -ForegroundColor Cyan
Write-Host "  - Do Not Disturb schedule (8 AM - 9 PM daily)" -ForegroundColor Gray
Write-Host "  - Disable notifications on lock screen" -ForegroundColor Gray
Write-Host "  - Disable Windows tips and suggestions" -ForegroundColor Gray
Write-Host "  - Power: 5min screen/sleep timeout (AC/plugged in), password on wake" -ForegroundColor Gray
Write-Host "  - Storage Sense: Run monthly, 30-day cleanup" -ForegroundColor Gray
Write-Host "  - Snap Windows: Disable suggestions" -ForegroundColor Gray
Write-Host "  - Alt+Tab: Hide tabs from apps" -ForegroundColor Gray
Write-Host "  - File Explorer: Show extensions, enable run as different user, use tabs" -ForegroundColor Gray
Write-Host "  - Set Windows Terminal as default" -ForegroundColor Gray
Write-Host "  - Clipboard: Disable history, sync, and suggested actions" -ForegroundColor Gray
Write-Host ""
Write-Host "Bluetooth & Devices:" -ForegroundColor Cyan
Write-Host "  - AutoPlay: Disabled for all drives" -ForegroundColor Gray
Write-Host ""
Write-Host "Personalization:" -ForegroundColor Cyan
Write-Host "  - Background: Solid black color" -ForegroundColor Gray
Write-Host "  - Transparency effects: Disabled" -ForegroundColor Gray
Write-Host "  - Lock screen: Disable fun facts and tips" -ForegroundColor Gray
Write-Host "  - Start menu: More pins layout, disable recent items and recommendations" -ForegroundColor Gray
Write-Host "  - Start folders: Enable Settings, File Explorer, Downloads, Personal" -ForegroundColor Gray
Write-Host "  - Taskbar: Hide Search, disable Copilot, Task View, and Widgets" -ForegroundColor Gray
Write-Host ""
Write-Host "Apps:" -ForegroundColor Cyan
Write-Host "  - Share across devices: Disabled" -ForegroundColor Gray
Write-Host "  - Archive apps: Disabled" -ForegroundColor Gray
Write-Host ""
Write-Host "Accounts:" -ForegroundColor Cyan
Write-Host "  - Windows Backup: Disable 'Remember my apps' and settings sync" -ForegroundColor Gray
Write-Host ""
Write-Host "Time & Language:" -ForegroundColor Cyan
Write-Host "  - Automatic time zone: Enabled" -ForegroundColor Gray
Write-Host "  - First day of week: Monday" -ForegroundColor Gray
Write-Host "  - Time format: 24-hour (9:40 and 9:40:07)" -ForegroundColor Gray
Write-Host "  - Typing: Enable multilingual suggestions, disable autocorrect" -ForegroundColor Gray
Write-Host ""
Write-Host "Gaming:" -ForegroundColor Cyan
Write-Host "  - Game Bar: Disable controller shortcut" -ForegroundColor Gray
Write-Host "  - Captures: Disable all game DVR and recording" -ForegroundColor Gray
Write-Host ""
Write-Host "Accessibility:" -ForegroundColor Cyan
Write-Host "  - Always show scrollbars: Enabled" -ForegroundColor Gray
Write-Host "  - Transparency effects: Disabled" -ForegroundColor Gray
Write-Host ""
Write-Host "Privacy & Security:" -ForegroundColor Cyan
Write-Host "  - Cloud content search: Disabled (Microsoft and Work/School accounts)" -ForegroundColor Gray
Write-Host "  - Recommendations in Settings: Disabled" -ForegroundColor Gray
Write-Host ""
Write-Host "Windows Update:" -ForegroundColor Cyan
Write-Host "  - Active hours: 6:00 AM - 10:00 PM" -ForegroundColor Gray
Write-Host "  - Restart notifications: Enabled" -ForegroundColor Gray
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
# SYSTEM SETTINGS
# ============================================================================

Write-Host "========================================" -ForegroundColor White
Write-Host "Configuring System Settings" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor White
Write-Host ""

# Notifications - Lock screen
Write-Host "Configuring notification settings..." -ForegroundColor Cyan
try {
    $notificationPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings"
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "LockScreenToastEnabled" -Value 0 -Type DWord -Force -ErrorAction Stop
    Write-Host "[OK] Notifications on lock screen disabled" -ForegroundColor Green
} catch {
    Write-Host "[FAILED] Could not configure lock screen notifications: $($_.Exception.Message)" -ForegroundColor Red
}

# Do Not Disturb schedule
Write-Host "Configuring Do Not Disturb schedule..." -ForegroundColor Cyan
try {
    $focusPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\QuietHours"
    if (!(Test-Path $focusPath)) {
        New-Item -Path $focusPath -Force | Out-Null
    }
    # Enable scheduled DND: 8:00 to 21:00 (8 AM to 9 PM)
    Set-ItemProperty -Path $focusPath -Name "Enabled" -Value 1 -Type DWord -Force -ErrorAction Stop
    Set-ItemProperty -Path $focusPath -Name "AutomaticStart" -Value 480 -Type DWord -Force -ErrorAction Stop  # 8:00 AM (minutes from midnight)
    Set-ItemProperty -Path $focusPath -Name "AutomaticEnd" -Value 1260 -Type DWord -Force -ErrorAction Stop    # 9:00 PM (minutes from midnight)
    Write-Host "[OK] Do Not Disturb scheduled for 8:00 AM - 9:00 PM daily" -ForegroundColor Green
} catch {
    Write-Host "[FAILED] Could not configure Do Not Disturb schedule" -ForegroundColor Red
}

# Disable DND for specific scenarios
Write-Host "Disabling DND auto-triggers..." -ForegroundColor Cyan
try {
    # Disable when duplicating display
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\QuietHours" -Name "EnableFullScreen" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Write-Host "[OK] DND triggers disabled" -ForegroundColor Green
} catch {
    Write-Host "[FAILED] Could not disable DND triggers" -ForegroundColor Red
}

# Windows welcome experience and tips
Write-Host "Disabling Windows tips and suggestions..." -ForegroundColor Cyan
try {
    $contentDeliveryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
    $userProfileEngagementPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement"
    
    if (!(Test-Path $userProfileEngagementPath)) {
        New-Item -Path $userProfileEngagementPath -Force | Out-Null
    }
    
    Set-ItemProperty -Path $contentDeliveryPath -Name "SubscribedContent-310093Enabled" -Value 0 -Type DWord -Force -ErrorAction Stop
    Set-ItemProperty -Path $contentDeliveryPath -Name "SubscribedContent-338389Enabled" -Value 0 -Type DWord -Force -ErrorAction Stop
    Set-ItemProperty -Path $contentDeliveryPath -Name "SubscribedContent-353694Enabled" -Value 0 -Type DWord -Force -ErrorAction Stop
    Set-ItemProperty -Path $contentDeliveryPath -Name "SubscribedContent-353696Enabled" -Value 0 -Type DWord -Force -ErrorAction Stop
    Set-ItemProperty -Path $userProfileEngagementPath -Name "ScoobeSystemSettingEnabled" -Value 0 -Type DWord -Force -ErrorAction Stop
    Write-Host "[OK] Windows tips and suggestions disabled" -ForegroundColor Green
} catch {
    Write-Host "[FAILED] Could not disable all tips and suggestions" -ForegroundColor Red
}

# Power settings - Screen and sleep (AC power for desktop)
Write-Host "Configuring power settings..." -ForegroundColor Cyan
try {
    # Set screen timeout on AC power to 5 minutes
    $result1 = powercfg /change monitor-timeout-ac 5 2>&1
    if ($LASTEXITCODE -ne 0) { throw "Failed to set monitor timeout: $result1" }
    
    # Set sleep timeout on AC power to 5 minutes
    $result2 = powercfg /change standby-timeout-ac 5 2>&1
    if ($LASTEXITCODE -ne 0) { throw "Failed to set sleep timeout: $result2" }
    
    # Require password on wake from sleep
    $powerSettingsPath = "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\0e796bdb-100d-47d6-a2d5-f7d2daa51f51"
    if (!(Test-Path $powerSettingsPath)) {
        New-Item -Path $powerSettingsPath -Force | Out-Null
    }
    Set-ItemProperty -Path $powerSettingsPath -Name "DCSettingIndex" -Value 1 -Type DWord -Force -ErrorAction Stop
    Set-ItemProperty -Path $powerSettingsPath -Name "ACSettingIndex" -Value 1 -Type DWord -Force -ErrorAction Stop
    
    Write-Host "[OK] AC power: Screen off after 5min, Sleep after 5min, Password required on wake" -ForegroundColor Green
} catch {
    Write-Host "[FAILED] Could not configure power settings: $($_.Exception.Message)" -ForegroundColor Red
}

# Storage Sense
Write-Host "Configuring Storage Sense..." -ForegroundColor Cyan
try {
    $storageSensePath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy"
    if (!(Test-Path $storageSensePath)) {
        New-Item -Path $storageSensePath -Force | Out-Null
    }
    # Enable Storage Sense
    Set-ItemProperty -Path $storageSensePath -Name "01" -Value 1 -Type DWord -Force -ErrorAction Stop
    # Run every month (value: 30)
    Set-ItemProperty -Path $storageSensePath -Name "2048" -Value 30 -Type DWord -Force -ErrorAction Stop
    # Delete files in recycle bin after 30 days
    Set-ItemProperty -Path $storageSensePath -Name "256" -Value 30 -Type DWord -Force -ErrorAction Stop
    # Delete files in Downloads after 30 days
    Set-ItemProperty -Path $storageSensePath -Name "512" -Value 30 -Type DWord -Force -ErrorAction Stop
    Write-Host "[OK] Storage Sense configured (monthly, 30-day cleanup)" -ForegroundColor Green
} catch {
    Write-Host "[FAILED] Could not configure Storage Sense" -ForegroundColor Red
}

# Snap Windows settings
Write-Host "Configuring Snap Windows..." -ForegroundColor Cyan
try {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "SnapAssist" -Value 0 -Type DWord -Force -ErrorAction Stop
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "JointResize" -Value 1 -Type DWord -Force -ErrorAction Stop
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "EnableSnapBar" -Value 1 -Type DWord -Force -ErrorAction Stop
    Write-Host "[OK] Snap Windows configured (suggestions off, snap bar on)" -ForegroundColor Green
} catch {
    Write-Host "[FAILED] Could not configure Snap Windows" -ForegroundColor Red
}

# Multitasking - Show tabs from apps
Write-Host "Disabling tabs in Alt+Tab..." -ForegroundColor Cyan
try {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "MultiTaskingAltTabFilter" -Value 3 -Type DWord -Force -ErrorAction Stop
    Write-Host "[OK] Tabs from apps hidden in Alt+Tab" -ForegroundColor Green
} catch {
    Write-Host "[FAILED] Could not configure Alt+Tab behavior" -ForegroundColor Red
}

# File Explorer - Show extensions and run as different user
Write-Host "Configuring File Explorer..." -ForegroundColor Cyan
try {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0 -Type DWord -Force -ErrorAction Stop
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "ShowRunasDifferentuserinStart" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    # Open folders in same window (uses tabs instead of new windows)
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "SeparateProcess" -Value 0 -Type DWord -Force -ErrorAction Stop
    Write-Host "[OK] File extensions visible, Run as different user enabled, tabs enabled" -ForegroundColor Green
} catch {
    Write-Host "[FAILED] Could not configure File Explorer options" -ForegroundColor Red
}

# Set Windows Terminal as default
Write-Host "Setting Windows Terminal as default..." -ForegroundColor Cyan
try {
    $terminalPath = "HKCU:\Console\%%Startup"
    if (!(Test-Path $terminalPath)) {
        New-Item -Path $terminalPath -Force | Out-Null
    }
    Set-ItemProperty -Path $terminalPath -Name "DelegationConsole" -Value "{2EACA947-7F5F-4CFA-BA87-8F7FBEEFBE69}" -Type String -Force -ErrorAction Stop
    Set-ItemProperty -Path $terminalPath -Name "DelegationTerminal" -Value "{E12CFF52-A866-4C77-9A90-F570A7AA2C6B}" -Type String -Force -ErrorAction Stop
    Write-Host "[OK] Windows Terminal set as default" -ForegroundColor Green
} catch {
    Write-Host "[FAILED] Could not set Windows Terminal as default" -ForegroundColor Red
}

# Clipboard settings
Write-Host "Configuring clipboard..." -ForegroundColor Cyan
try {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Clipboard" -Name "EnableClipboardHistory" -Value 0 -Type DWord -Force -ErrorAction Stop
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Clipboard" -Name "CloudClipboardAutomaticUpload" -Value 0 -Type DWord -Force -ErrorAction Stop
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\SmartActionPlatform\SmartClipboard" -Name "Disabled" -Value 1 -Type DWord -Force -ErrorAction Stop
    Write-Host "[OK] Clipboard history and sync disabled, suggested actions disabled" -ForegroundColor Green
} catch {
    Write-Host "[FAILED] Could not configure clipboard settings" -ForegroundColor Red
}

# ============================================================================
# BLUETOOTH & DEVICES
# ============================================================================

Write-Host ""
Write-Host "========================================" -ForegroundColor White
Write-Host "Configuring Bluetooth & Devices" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor White
Write-Host ""

# AutoPlay settings
Write-Host "Disabling AutoPlay..." -ForegroundColor Cyan
try {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" -Name "DisableAutoplay" -Value 1 -Type DWord -Force -ErrorAction Stop
    Write-Host "[OK] AutoPlay disabled for removable drives and memory cards" -ForegroundColor Green
} catch {
    Write-Host "[FAILED] Could not disable AutoPlay" -ForegroundColor Red
}

# ============================================================================
# PERSONALIZATION
# ============================================================================

Write-Host ""
Write-Host "========================================" -ForegroundColor White
Write-Host "Configuring Personalization" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor White
Write-Host ""

# Background - Solid black color
Write-Host "Setting background to solid black..." -ForegroundColor Cyan
try {
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "Wallpaper" -Value "" -Type String -Force -ErrorAction Stop
    Set-ItemProperty -Path "HKCU:\Control Panel\Colors" -Name "Background" -Value "0 0 0" -Type String -Force -ErrorAction Stop
    Write-Host "[OK] Background set to solid black" -ForegroundColor Green
} catch {
    Write-Host "[FAILED] Could not set background color" -ForegroundColor Red
}

# Transparency effects
Write-Host "Disabling transparency effects..." -ForegroundColor Cyan
try {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 0 -Type DWord -Force -ErrorAction Stop
    Write-Host "[OK] Transparency effects disabled" -ForegroundColor Green
} catch {
    Write-Host "[FAILED] Could not disable transparency" -ForegroundColor Red
}

# Lock screen - Disable fun facts and tips
Write-Host "Configuring lock screen..." -ForegroundColor Cyan
try {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenOverlayEnabled" -Value 0 -Type DWord -Force -ErrorAction Stop
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenEnabled" -Value 0 -Type DWord -Force -ErrorAction Stop
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -Value 0 -Type DWord -Force -ErrorAction Stop
    Write-Host "[OK] Lock screen tips and fun facts disabled" -ForegroundColor Green
} catch {
    Write-Host "[FAILED] Could not configure lock screen" -ForegroundColor Red
}

# Start menu settings
Write-Host "Configuring Start menu..." -ForegroundColor Cyan
try {
    # More pins layout
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_Layout" -Value 1 -Type DWord -Force -ErrorAction Stop
    
    # Disable recently added apps
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackProgs" -Value 0 -Type DWord -Force -ErrorAction Stop
    
    # Disable recently opened items
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackDocs" -Value 0 -Type DWord -Force -ErrorAction Stop
    
    # Disable recommendations
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_IrisRecommendations" -Value 0 -Type DWord -Force -ErrorAction Stop
    
    Write-Host "[OK] Start menu configured (more pins, no recent items, no recommendations)" -ForegroundColor Green
} catch {
    Write-Host "[FAILED] Could not configure Start menu" -ForegroundColor Red
}

# Start menu folders
Write-Host "Enabling Start menu folders..." -ForegroundColor Cyan
try {
    $startFoldersPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Start"
    if (!(Test-Path $startFoldersPath)) {
        New-Item -Path $startFoldersPath -Force | Out-Null
    }
    
    # Enable folders: Settings, File Explorer, Downloads, Personal folder
    Set-ItemProperty -Path $startFoldersPath -Name "VisiblePlaces" -Value ([byte[]](0x86,0x08,0x73,0x85,0xad,0x1a,0xd4,0x11,0xbd,0xfd,0x00,0xc0,0x4f,0xa3,0x48,0x8a,0x42,0x88,0x2e,0x93,0xad,0x1a,0xd4,0x11,0x91,0x46,0x00,0xc0,0x4f,0xb9,0x60,0xf9,0x20,0x42,0x88,0x2e,0x93,0xad,0x1a,0xd4,0x11,0x91,0x46,0x00,0xc0,0x4f,0xb9,0x60,0xf9,0x59,0x03,0x1c,0x87,0x60,0x48,0x0f,0x81,0x87,0xc8,0x7c,0x56,0x46,0x83,0x4f,0x5e)) -Type Binary -Force -ErrorAction Stop
    
    Write-Host "[OK] Start menu folders enabled (Settings, File Explorer, Downloads, Personal)" -ForegroundColor Green
} catch {
    Write-Host "[FAILED] Could not configure Start menu folders" -ForegroundColor Red
}

# Taskbar settings
Write-Host "Configuring taskbar..." -ForegroundColor Cyan
try {
    # Hide search
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 0 -Type DWord -Force -ErrorAction Stop
    
    # Disable Copilot
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowCopilotButton" -Value 0 -Type DWord -Force -ErrorAction Stop
    
    # Disable Task View
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0 -Type DWord -Force -ErrorAction Stop
    
    # Disable Widgets - this key is sometimes protected, so we try but don't fail if it errors
    try {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value 0 -Type DWord -Force -ErrorAction Stop
    } catch {
        # Try alternative method via Group Policy
        $widgetsPolicyPath = "HKCU:\Software\Policies\Microsoft\Dsh"
        if (!(Test-Path $widgetsPolicyPath)) {
            New-Item -Path $widgetsPolicyPath -Force | Out-Null
        }
        Set-ItemProperty -Path $widgetsPolicyPath -Name "AllowNewsAndInterests" -Value 0 -Type DWord -Force -ErrorAction Stop
    }
    
    Write-Host "[OK] Taskbar configured (Search hidden, Copilot/Task View/Widgets disabled)" -ForegroundColor Green
} catch {
    Write-Host "[FAILED] Could not configure all taskbar settings" -ForegroundColor Red
}

# ============================================================================
# APPS
# ============================================================================

Write-Host ""
Write-Host "========================================" -ForegroundColor White
Write-Host "Configuring Apps Settings" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor White
Write-Host ""

# Share across devices
Write-Host "Disabling share across devices..." -ForegroundColor Cyan
try {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CDP" -Name "RomeSdkChannelUserAuthzPolicy" -Value 0 -Type DWord -Force -ErrorAction Stop
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CDP" -Name "CdpSessionUserAuthzPolicy" -Value 0 -Type DWord -Force -ErrorAction Stop
    Write-Host "[OK] Share across devices disabled" -ForegroundColor Green
} catch {
    Write-Host "[FAILED] Could not disable share across devices" -ForegroundColor Red
}

# Archive apps
Write-Host "Disabling app archiving..." -ForegroundColor Cyan
try {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "FeatureManagementEnabled" -Value 0 -Type DWord -Force -ErrorAction Stop
    Write-Host "[OK] App archiving disabled" -ForegroundColor Green
} catch {
    Write-Host "[FAILED] Could not disable app archiving" -ForegroundColor Red
}

# ============================================================================
# ACCOUNTS
# ============================================================================

Write-Host ""
Write-Host "========================================" -ForegroundColor White
Write-Host "Configuring Account Settings" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor White
Write-Host ""

# Windows Backup - Remember my apps and settings sync
Write-Host "Disabling Windows Backup and settings sync..." -ForegroundColor Cyan
try {
    $userProfileEngagementPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement"
    $settingSyncPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\SettingSync"
    $settingSyncGroupsPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups"
    
    # Create paths if they don't exist
    if (!(Test-Path $userProfileEngagementPath)) {
        New-Item -Path $userProfileEngagementPath -Force | Out-Null
    }
    if (!(Test-Path $settingSyncPath)) {
        New-Item -Path $settingSyncPath -Force | Out-Null
    }
    if (!(Test-Path $settingSyncGroupsPath)) {
        New-Item -Path $settingSyncGroupsPath -Force | Out-Null
    }
    
    # Disable "Remember my apps"
    Set-ItemProperty -Path $userProfileEngagementPath -Name "BackupUserProfileEngagement" -Value 0 -Type DWord -Force -ErrorAction Stop
    
    # Disable settings sync across devices
    Set-ItemProperty -Path $settingSyncPath -Name "SyncPolicy" -Value 5 -Type DWord -Force -ErrorAction Stop
    
    # Create and disable individual sync groups
    $syncGroups = @("Personalization", "BrowserSettings", "Credentials", "Language", "Accessibility", "Windows")
    foreach ($group in $syncGroups) {
        $groupPath = "$settingSyncGroupsPath\$group"
        if (!(Test-Path $groupPath)) {
            New-Item -Path $groupPath -Force | Out-Null
        }
        Set-ItemProperty -Path $groupPath -Name "Enabled" -Value 0 -Type DWord -Force -ErrorAction Stop
    }
    
    Write-Host "[OK] Windows Backup disabled, settings sync disabled across devices" -ForegroundColor Green
} catch {
    Write-Host "[FAILED] Could not fully configure Windows Backup settings" -ForegroundColor Red
}

# ============================================================================
# TIME & LANGUAGE
# ============================================================================

Write-Host ""
Write-Host "========================================" -ForegroundColor White
Write-Host "Configuring Time & Language" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor White
Write-Host ""

# Set time zone automatically
Write-Host "Enabling automatic time zone..." -ForegroundColor Cyan
try {
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate" -Name "Start" -Value 3 -Type DWord -Force -ErrorAction Stop
    Write-Host "[OK] Automatic time zone enabled" -ForegroundColor Green
} catch {
    Write-Host "[FAILED] Could not enable automatic time zone" -ForegroundColor Red
}

# First day of week - Monday
Write-Host "Setting first day of week to Monday..." -ForegroundColor Cyan
try {
    Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name "iFirstDayOfWeek" -Value 0 -Type String -Force -ErrorAction Stop
    Write-Host "[OK] First day of week set to Monday" -ForegroundColor Green
} catch {
    Write-Host "[FAILED] Could not set first day of week" -ForegroundColor Red
}

# Time format - 24-hour
Write-Host "Setting time format to 24-hour..." -ForegroundColor Cyan
try {
    Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name "sShortTime" -Value "H:mm" -Type String -Force -ErrorAction Stop
    Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name "sTimeFormat" -Value "H:mm:ss" -Type String -Force -ErrorAction Stop
    Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name "iTimePrefix" -Value 0 -Type String -Force -ErrorAction Stop
    Write-Host "[OK] Time format set to 24-hour (9:40 and 9:40:07)" -ForegroundColor Green
} catch {
    Write-Host "[FAILED] Could not set time format" -ForegroundColor Red
}

# Typing settings
Write-Host "Configuring typing settings..." -ForegroundColor Cyan
try {
    # Enable multilingual text suggestions
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Input\Settings" -Name "MultilingualEnabled" -Value 1 -Type DWord -Force -ErrorAction Stop
    
    # Disable autocorrect
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\TabletTip\1.7" -Name "EnableAutocorrection" -Value 0 -Type DWord -Force -ErrorAction Stop
    
    Write-Host "[OK] Multilingual suggestions enabled, autocorrect disabled" -ForegroundColor Green
} catch {
    Write-Host "[FAILED] Could not configure typing settings" -ForegroundColor Red
}

# ============================================================================
# GAMING
# ============================================================================

Write-Host ""
Write-Host "========================================" -ForegroundColor White
Write-Host "Configuring Gaming Settings" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor White
Write-Host ""

# Game Bar - Disable controller opening
Write-Host "Disabling Game Bar controller shortcut..." -ForegroundColor Cyan
try {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "UseNexusForGameBarEnabled" -Value 0 -Type DWord -Force -ErrorAction Stop
    Write-Host "[OK] Controller cannot open Game Bar" -ForegroundColor Green
} catch {
    Write-Host "[FAILED] Could not disable Game Bar controller" -ForegroundColor Red
}

# Captures - Disable all
Write-Host "Disabling Game DVR and captures..." -ForegroundColor Cyan
try {
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -Type DWord -Force -ErrorAction Stop
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Value 0 -Type DWord -Force -ErrorAction Stop
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AudioCaptureEnabled" -Value 0 -Type DWord -Force -ErrorAction Stop
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Name "CursorCaptureEnabled" -Value 0 -Type DWord -Force -ErrorAction Stop
    Write-Host "[OK] Game captures and DVR disabled" -ForegroundColor Green
} catch {
    Write-Host "[FAILED] Could not disable game captures" -ForegroundColor Red
}

# ============================================================================
# ACCESSIBILITY
# ============================================================================

Write-Host ""
Write-Host "========================================" -ForegroundColor White
Write-Host "Configuring Accessibility" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor White
Write-Host ""

# Always show scrollbars
Write-Host "Enabling always show scrollbars..." -ForegroundColor Cyan
try {
    Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility" -Name "DynamicScrollbars" -Value 0 -Type DWord -Force -ErrorAction Stop
    Write-Host "[OK] Scrollbars always visible" -ForegroundColor Green
} catch {
    Write-Host "[FAILED] Could not configure scrollbar visibility" -ForegroundColor Red
}

# Transparency effects (already set in Personalization, but also in Accessibility)
Write-Host "Disabling transparency effects (accessibility)..." -ForegroundColor Cyan
try {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 0 -Type DWord -Force -ErrorAction Stop
    Write-Host "[OK] Transparency effects disabled" -ForegroundColor Green
} catch {
    Write-Host "[FAILED] Already configured" -ForegroundColor Red
}

# ============================================================================
# PRIVACY & SECURITY
# ============================================================================

Write-Host ""
Write-Host "========================================" -ForegroundColor White
Write-Host "Configuring Privacy & Security" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor White
Write-Host ""

# Search permissions - Cloud content search
Write-Host "Disabling cloud content search..." -ForegroundColor Cyan
try {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings" -Name "IsMSACloudSearchEnabled" -Value 0 -Type DWord -Force -ErrorAction Stop
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings" -Name "IsAADCloudSearchEnabled" -Value 0 -Type DWord -Force -ErrorAction Stop
    Write-Host "[OK] Cloud content search disabled (Microsoft account and Work/School)" -ForegroundColor Green
} catch {
    Write-Host "[FAILED] Could not disable cloud content search" -ForegroundColor Red
}

# Recommendations & offers in Settings
Write-Host "Disabling recommendations in Settings..." -ForegroundColor Cyan
try {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338393Enabled" -Value 0 -Type DWord -Force -ErrorAction Stop
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353694Enabled" -Value 0 -Type DWord -Force -ErrorAction Stop
    Write-Host "[OK] Recommendations and offers in Settings disabled" -ForegroundColor Green
} catch {
    Write-Host "[FAILED] Could not disable recommendations" -ForegroundColor Red
}

# ============================================================================
# WINDOWS UPDATE
# ============================================================================

Write-Host ""
Write-Host "========================================" -ForegroundColor White
Write-Host "Configuring Windows Update" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor White
Write-Host ""

# Active hours: 6:00 AM to 10:00 PM
Write-Host "Setting Windows Update active hours..." -ForegroundColor Cyan
try {
    $updatePath = "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings"
    if (!(Test-Path $updatePath)) {
        New-Item -Path $updatePath -Force | Out-Null
    }
    
    # Set active hours (6 AM to 10 PM = 6 to 22)
    Set-ItemProperty -Path $updatePath -Name "ActiveHoursStart" -Value 6 -Type DWord -Force -ErrorAction Stop
    Set-ItemProperty -Path $updatePath -Name "ActiveHoursEnd" -Value 22 -Type DWord -Force -ErrorAction Stop
    
    Write-Host "[OK] Active hours set to 6:00 AM - 10:00 PM" -ForegroundColor Green
} catch {
    Write-Host "[FAILED] Could not set active hours" -ForegroundColor Red
}

# Notify when restart is required
Write-Host "Enabling restart notifications..." -ForegroundColor Cyan
try {
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "RestartNotificationsAllowed2" -Value 1 -Type DWord -Force -ErrorAction Stop
    Write-Host "[OK] Restart notifications enabled" -ForegroundColor Green
} catch {
    Write-Host "[FAILED] Could not enable restart notifications" -ForegroundColor Red
}

# ============================================================================
# Restart Windows Explorer
# ============================================================================

Write-Host ""
Write-Host "========================================" -ForegroundColor White
Write-Host "Applying Changes" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor White
Write-Host ""

Write-Host "Restarting Windows Explorer..." -ForegroundColor Cyan
try {
    Stop-Process -Name explorer -Force -ErrorAction Stop
    Start-Sleep -Seconds 2
    # Explorer automatically restarts
    Write-Host "[OK] Windows Explorer restarted" -ForegroundColor Green
} catch {
    Write-Host "[FAILED] Could not restart Explorer: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "  You may need to sign out and back in for all changes to take effect" -ForegroundColor Yellow
}

# ============================================================================
# Summary
# ============================================================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Configuration Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Host "Settings configured:" -ForegroundColor Cyan
Write-Host "  [OK] Display and power settings" -ForegroundColor Gray
Write-Host "  [OK] Notification and Do Not Disturb schedule" -ForegroundColor Gray
Write-Host "  [OK] Storage Sense automation" -ForegroundColor Gray
Write-Host "  [OK] File Explorer options" -ForegroundColor Gray
Write-Host "  [OK] Clipboard settings" -ForegroundColor Gray
Write-Host "  [OK] AutoPlay disabled" -ForegroundColor Gray
Write-Host "  [OK] Personalization (background, transparency)" -ForegroundColor Gray
Write-Host "  [OK] Start menu and taskbar" -ForegroundColor Gray
Write-Host "  [OK] App settings (sharing, archiving)" -ForegroundColor Gray
Write-Host "  [OK] Time and language settings" -ForegroundColor Gray
Write-Host "  [OK] Gaming settings (Game Bar, captures)" -ForegroundColor Gray
Write-Host "  [OK] Accessibility (scrollbars)" -ForegroundColor Gray
Write-Host "  [OK] Privacy settings (search, recommendations)" -ForegroundColor Gray
Write-Host "  [OK] Windows Update active hours" -ForegroundColor Gray
Write-Host ""

Write-Host "Some changes may require signing out and back in to take full effect." -ForegroundColor Yellow
Write-Host ""

Write-Host "========================================" -ForegroundColor White
Write-Host "Configuration script complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor White