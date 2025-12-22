# Windows 11 Setup Automation

Automated scripts to set up a fresh Windows 11 installation with privacy-focused settings, minimal bloatware, and essential development tools. This was last tested with Windows 11 25H2.

## 📋 What This Does

This repository contains PowerShell scripts that automate ~80-90% of a fresh Windows 11 setup:

- ✅ **Remove bloatware** - Bing apps, OneDrive, Teams, etc.
- ✅ **Install applications** - Software for common tasks
- ✅ **Configure privacy** - Disable telemetry, web search, widgets
- ✅ **Set up WSL** - Ubuntu Linux for development
- ✅ **Optimize system settings** - Power, notifications, File Explorer
- ✅ **Enhance security** - Require admin passwords for system changes

## 📦 What Gets Installed

### Applications (via install_apps_user.ps1)

**Development:**
- VS Code
- Windows Subsystem for Linux (Ubuntu)

**Productivity:**
- LibreOffice

**Utilities:**
- VLC Media Player
- Microsoft PowerToys

### What Gets Removed (via remove_bloatware.ps1)

- Bing News, Weather, Search
- Microsoft Solitaire Collection
- Microsoft To Do
- Your Phone
- Sticky Notes
- Outlook for Windows
- Microsoft OneDrive
- Microsoft Teams

## 🔧 Setup Guide

### Prerequisites

- Fresh Windows 11 installation
- Windows 11 **Pro** (required for some security features)
- Internet connection

### Download This Repository

1. Go to https://github.com/jeffmaher/computer-setup
1. Click **Code** → **Download ZIP**
1. Extract the ZIP file (e.g., to `C:\temp\computer-setup`)
1. Open PowerShell and navigate to the extracted folder:
   ```powershell
   cd C:\temp\computer-setup\computer-setup-main
   ```

### Fresh Windows Install

Before running any scripts, complete the initial Windows setup:

**Welcome prompts answers:**
- Language: English (US)
- Country: Canada (or your country)
- Keyboard: United States
- Sign in with your Microsoft account
- **Windows Hello**: Skip for now, add PIN later
- **Location services**: Yes
- **Find my device**: No
- **Diagnostic data**: Required only
- **Tailored experiences**: No
- **Advertising ID**: No

**Upgrade to Windows 11 Pro:**
1. Search Start Menu for "activation settings"
1. Update to Pro from Microsoft Store
1. Restart

### Configure UAC (Admin Password Required)

**Requires**: Administrator  
**Time**: <1 minute

**How to run:**
1. Click **Start Menu**
1. Type **"PowerShell"**
1. Right-click **Windows PowerShell**
1. Select **"Run as Administrator"**
1. Click **Yes** on the UAC prompt
1. Run the command below:

Ensures Windows always asks for your admin password before making system changes.

```powershell
PowerShell -ExecutionPolicy Bypass -File .\windows-11\configure_uac.ps1
```

**What it does:**
- Sets UAC to always prompt for credentials
- Uses secure desktop (prevents spoofing)
- Applies to both admin and standard users

### Disable OneDrive (If Not Using)

**Requires**: No terminal needed  
**Time**: 2 minutes

If you don't use OneDrive/Microsoft 365, disable it before removing bloatware:

1. System tray → OneDrive → Settings
1. **Sync & Backup**: Turn off all folder backups
1. **Account**: Unlink this PC
1. System tray → OneDrive → Quit OneDrive

### Remove Bloatware

**Requires**: Administrator  
**Time**: 2-5 minutes

**How to run:**
1. Open **PowerShell as Administrator** (same as Step 1)
1. Run the command below:

Removes pre-installed Windows apps you don't need.

```powershell
PowerShell -ExecutionPolicy Bypass -File .\windows-11\remove_bloatware.ps1
```

**What it removes:**
- Bing apps (News, Weather, Search)
- Microsoft games and extras
- OneDrive and Teams
- See script for full list

**Customization:**
Edit `remove_bloatware.ps1` to add/remove apps from the removal list.

### Disable Web Search

**Requires**: Administrator  
**Time**: <1 minute

**How to run:**
1. Open **PowerShell as Administrator** (same as Step 1)
1. Run the command below:

Disables Bing web results in Start Menu search (local apps/files only).

```powershell
PowerShell -ExecutionPolicy Bypass -File .\windows-11\disable_web_search.ps1
```

**What it does:**
- Makes Start Menu search local-only (apps and files)
- No more Bing web results cluttering your search
- Better privacy (no search queries sent to Microsoft)
- Reduced network usage

### Install WSL (Windows Subsystem for Linux)

**Requires**: Administrator  
**Time**: 5 minutes (run twice)

**How to run:**
1. Open **PowerShell as Administrator** (same as Step 1)
1. Run the command below:

Installs Ubuntu Linux for development.

```powershell
PowerShell -ExecutionPolicy Bypass -File .\windows-11\install_wsl.ps1
```

**⚠️ Important**: Run this script **twice**:
1. **First run**: Enables WSL features → **Restart required**
1. **After restart**: Open **PowerShell as Administrator** again and run the same command
1. **Second run**: Installs Ubuntu
1. Open **Windows Terminal** or search for **"Ubuntu"** in Start Menu
1. Ubuntu will start and prompt you to create a username and password
1. After setup, run these commands in the **Ubuntu terminal**:

```bash
# Update Ubuntu packages
sudo apt update && sudo apt upgrade -y
sudo apt install zip unzip -y
exit
```

**Set Ubuntu as default terminal** (optional):
1. Open Windows Terminal
1. Click **▼** next to **+**
1. Go to **Settings**
1. Change **Default profile** to **Ubuntu**
1. **Save**

### Install Applications

**Requires**: Standard user (NOT admin)  
**Time**: 20-30 minutes

**How to run:**
1. Open **PowerShell** as a **normal user** (NOT as Administrator)
   - Click **Start Menu**
   - Type **"PowerShell"**
   - Click **Windows PowerShell** (do NOT right-click or run as admin)
1. Navigate to the repository folder if not already there:
   ```powershell
   cd C:\temp\computer-setup\computer-setup-main
   ```
1. Run the command below:

Installs all your apps in one go.

```powershell
PowerShell -ExecutionPolicy Bypass -File .\windows-11\install_apps_user.ps1
```

**⚠️ Run as STANDARD USER** (not admin!)

**What to expect:**
- Most apps install silently
- Some apps (LibreOffice, VLC, Zoom, Docker) will show UAC prompts
- Enter your admin password when prompted
- Script continues automatically

**Customization:**

To add apps:
1. Find the app ID at https://winstall.app/
1. Add to the `$apps` array in `install_apps_user.ps1`:
   ```powershell
   @{ id = "Notepad++.Notepad++"; name = "Notepad++" }
   ```

To remove apps: Comment out or delete the line

### Configure System Settings

**Requires**: Administrator  
**Time**: 1-2 minutes

**How to run:**
1. Open **PowerShell as Administrator** (same as Step 1)
1. Run the command below:

Optimizes Windows settings for privacy, performance, and usability.

```powershell
PowerShell -ExecutionPolicy Bypass -File .\windows-11\configure_system_settings.ps1
```

**What it configures** (32 settings total):
- **System**: Do Not Disturb, power, Storage Sense, File Explorer
- **Privacy**: Disable cloud search, recommendations, settings sync
- **Personalization**: Start menu, taskbar, transparency
- **Gaming**: Disable Game Bar, DVR
- **Windows Update**: Active hours 6 AM - 10 PM

**Customization:**

Edit `configure_system_settings.ps1` to change:
- Power timeouts (currently 5 min)
- Do Not Disturb schedule (currently 8 AM - 9 PM)
- Active hours (currently 6 AM - 10 PM)
- Any other registry settings

## 🔐 Additional Manual Steps

Some things still require manual setup:

### Configure BitLocker Encryption

1. Search Start Menu for "manage bitlocker"
1. Turn on BitLocker
1. Print recovery key (save to cloud backup, not locally)
1. After encrypting, visit: https://account.microsoft.com/devices/recoverykey
1. **Delete the key** (removes it from Microsoft's servers)

### Install Hardware Drivers (If Needed)

Windows auto-installs most drivers, but you may need:
- [Logi Options+](https://www.logitech.com/en-ca/software/logi-options-plus.html) - Logitech devices
- [Nvidia App](https://www.nvidia.com/en-us/software/nvidia-app/) - NVIDIA graphics cards

### Configure LibreOffice

1. Set default file types (Writer→DOCX, Calc→XLSX, Impress→PPTX)
1. Enable auto-save
1. Disable recovery files

### Set Up SSH and GitHub

**Terminal**: Ubuntu/WSL terminal

1. Open **Ubuntu** from Start Menu or open **Windows Terminal** and select **Ubuntu** profile
1. Run:

```bash
bash ./ubuntu-linux/setup-ssh-and-git.sh
```

### Install Docker Desktop

**Requires**: Manual installation  
**Time**: 10 minutes

Docker Desktop lets you run containerized applications and development environments.

**Installation:**
1. Go to [Docker Desktop download page](https://www.docker.com/products/docker-desktop/)
2. Download the installer
3. Run the installer
4. When prompted, check **"Use WSL 2 instead of Hyper-V"**
5. **Restart** your computer
6. Agree to terms and conditions (or purchase if not eligible for free version)

**Configure Docker Desktop:**
1. Open Docker Desktop
2. Go to **Settings**
3. Under **General**, uncheck:
   - Start Docker Desktop when you sign in to your computer
   - Open Docker Dashboard when Docker Desktop starts
4. Click **Apply & restart**

### Manual System Settings

Things the scripts can't automate:
- Language packs (Settings → Time & language → Language)
- Audio enhancements per device
- Display configuration
- Default audio input/output devices

### Bluetooth Device Name (Optional)

To make devices pronounce your computer name instead of spelling it:

1. Start Menu → Device Manager
1. **Bluetooth** → Right-click your device
1. **Advanced** tab → Change name to lowercase
1. Toggle Bluetooth off/on to apply

## 🐛 Troubleshooting

### Script says "[FAILED]" for something

Check the error message. Common issues:
- Not running as Administrator (when required)
- App already installed
- Network connection problems
- App doesn't support user-scope installation

### WSL says "restart required"

Run the script once, restart Windows, then run the script again.

### Apps failed to install with error code -1978335216

The app doesn't support user-scope installation. The script automatically retries with system-wide installation and will show UAC prompt.

### Widgets still appear on taskbar

Run Windows Explorer restart:
```powershell
Stop-Process -Name explorer -Force
```

## 📄 License

MIT License - Feel free to use and modify

## 🙏 Contributing

Issues and pull requests welcome! This is a personal setup script made public, so your mileage may vary.

## ✨ Credits

Created by [Jeff Maher](https://github.com/jeffmaher)
