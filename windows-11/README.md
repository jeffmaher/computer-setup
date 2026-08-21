# Windows 11 Setup Automation

Automated scripts to set up a fresh Windows 11 installation with privacy-focused settings, minimal bloatware, and essential development tools.

## 📋 What This Does

This repository contains PowerShell scripts that automate ~80-90% of a fresh Windows 11 setup:

- ✅ **Remove bloatware** - Bing apps, OneDrive, Teams, etc.
- ✅ **Install applications** - Browsers, dev tools, productivity apps
- ✅ **Configure privacy** - Disable telemetry, web search, widgets
- ✅ **Set up WSL** - Ubuntu Linux for development
- ✅ **Optimize system settings** - Power, notifications, File Explorer
- ✅ **Enhance security** - Require admin passwords for system changes

## 📦 What Gets Installed

### Applications (via install_apps_user.ps1)

**Browsers:**
- Mozilla Firefox
- Google Chrome

**Development:**
- VS Code
- Docker Desktop
- Windows Subsystem for Linux (Ubuntu)

**Productivity:**
- LibreOffice
- 1Password
- Todoist
- Signal (+ Beta)
- Slack
- Zoom

**Utilities:**
- VLC Media Player
- Figma
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
2. Click **Code** → **Download ZIP**
3. Extract the ZIP file (e.g., to `C:\temp\computer-setup`)
4. Open PowerShell and navigate to the extracted folder:
   ```powershell
   cd C:\temp\computer-setup\computer-setup-main
   ```

### Step 0: Fresh Windows Install

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
2. Update to Pro from Microsoft Store
3. Restart

### Step 1: Configure UAC (Admin Password Required)

**Requires**: Administrator  
**Time**: <1 minute

**How to run:**
1. Click **Start Menu**
2. Type **"PowerShell"**
3. Right-click **Windows PowerShell**
4. Select **"Run as Administrator"**
5. Click **Yes** on the UAC prompt
6. Run the command below:

Ensures Windows always asks for your admin password before making system changes.

```powershell
PowerShell -ExecutionPolicy Bypass -File .\windows-11\configure_uac.ps1
```

**What it does:**
- Sets UAC to always prompt for credentials
- Uses secure desktop (prevents spoofing)
- Applies to both admin and standard users

### Step 2: Disable OneDrive (If Not Using)

**Requires**: No terminal needed  
**Time**: 2 minutes

If you don't use OneDrive/Microsoft 365, disable it before removing bloatware:

1. System tray → OneDrive → Settings
2. **Sync & Backup**: Turn off all folder backups
3. **Account**: Unlink this PC
4. System tray → OneDrive → Quit OneDrive

### Step 3: Remove Bloatware

**Requires**: Administrator  
**Time**: 2-5 minutes

**How to run:**
1. Open **PowerShell as Administrator** (same as Step 1)
2. Run the command below:

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

### Step 4: Disable Web Search

**Requires**: Administrator  
**Time**: <1 minute

**How to run:**
1. Open **PowerShell as Administrator** (same as Step 1)
2. Run the command below:

Disables Bing web results in Start Menu search (local apps/files only).

```powershell
PowerShell -ExecutionPolicy Bypass -File .\windows-11\disable_web_search.ps1
```

**What it does:**
- Makes Start Menu search local-only (apps and files)
- No more Bing web results cluttering your search
- Better privacy (no search queries sent to Microsoft)
- Reduced network usage

### Step 5: Install WSL (Windows Subsystem for Linux)

**Requires**: Administrator  
**Time**: 5 minutes (run twice)

**How to run:**
1. Open **PowerShell as Administrator** (same as Step 1)
2. Run the command below:

Installs Ubuntu Linux for development.

```powershell
PowerShell -ExecutionPolicy Bypass -File .\windows-11\install_wsl.ps1
```

**⚠️ Important**: Run this script **twice**:
1. **First run**: Enables WSL features → **Restart required**
2. **After restart**: Open **PowerShell as Administrator** again and run the same command
3. **Second run**: Installs Ubuntu

**After installation:**

1. Open **Windows Terminal** or search for **"Ubuntu"** in Start Menu
2. Ubuntu will start and prompt you to create a username and password
3. After setup, run these commands in the **Ubuntu terminal**:

```bash
# Update Ubuntu packages
sudo apt update && sudo apt upgrade -y
sudo apt install zip unzip -y
exit
```

**Set Ubuntu as default terminal** (optional):
1. Open Windows Terminal
2. Click **▼** next to **+**
3. Go to **Settings**
4. Change **Default profile** to **Ubuntu**
5. **Save**

### Step 6: Install Applications

**Requires**: Standard user (NOT admin)  
**Time**: 20-30 minutes

**How to run:**
1. Open **PowerShell** as a **normal user** (NOT as Administrator)
   - Click **Start Menu**
   - Type **"PowerShell"**
   - Click **Windows PowerShell** (do NOT right-click or run as admin)
2. Navigate to the repository folder if not already there:
   ```powershell
   cd C:\temp\computer-setup\computer-setup-main
   ```
3. Run the command below:

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
2. Add to the `$apps` array in `install_apps_user.ps1`:
   ```powershell
   @{ id = "Notepad++.Notepad++"; name = "Notepad++" }
   ```

To remove apps: Comment out or delete the line

### Step 7: Configure System Settings

**Requires**: Administrator  
**Time**: 1-2 minutes

**How to run:**
1. Open **PowerShell as Administrator** (same as Step 1)
2. Run the command below:

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

### 1. Configure BitLocker Encryption

1. Search Start Menu for "manage bitlocker"
2. Turn on BitLocker
3. Print recovery key (save to cloud backup, not locally)
4. After encrypting, visit: https://account.microsoft.com/devices/recoverykey
5. **Delete the key** (removes it from Microsoft's servers)

### 2. Install Hardware Drivers (If Needed)

Windows auto-installs most drivers, but you may need:
- [Logi Options+](https://www.logitech.com/en-ca/software/logi-options-plus.html) - Logitech devices
- [Nvidia App](https://www.nvidia.com/en-us/software/nvidia-app/) - NVIDIA graphics cards

### 3. Configure LibreOffice

1. Set default file types (Writer→DOCX, Calc→XLSX, Impress→PPTX)
2. Enable auto-save
3. Disable recovery files

### 4. Set Up SSH and GitHub

**Terminal**: Ubuntu/WSL terminal

1. Open **Ubuntu** from Start Menu or open **Windows Terminal** and select **Ubuntu** profile
2. Run:

```bash
bash ./ubuntu-linux/setup-ssh-and-git.sh
```

### 5. Install Docker Desktop

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

### 6. Manual System Settings

Things the scripts can't automate:
- Language packs (Settings → Time & language → Language)
- Audio enhancements per device
- Display configuration
- Default audio input/output devices

### 7. Bluetooth Device Name (Optional)

To make devices pronounce your computer name instead of spelling it:

1. Start Menu → Device Manager
2. **Bluetooth** → Right-click your device
3. **Advanced** tab → Change name to lowercase
4. Toggle Bluetooth off/on to apply

### 8. Clear Microsoft Account Data

Remove activity data Microsoft has stored in the cloud for your account. Sign in with your Microsoft account at each link, then use the **Clear** option in that section:

1. **Clear app and service data**: https://account.microsoft.com/privacy/apps-services
2. **Clear search history**: https://account.microsoft.com/privacy/web-search
3. **Clear browsing history**: https://account.microsoft.com/privacy/web-search

> **Note**: Browsing history and search history both live under the same `web-search` page on Microsoft's current privacy dashboard (browsing activity appears under "Recent activity"), so links 2 and 3 point to the same place. Clear each section shown there.

**Keep it cleared automatically (30-day retention):**

There's no per-section "clear every 30 days" dropdown to set. Instead, once you clear a category, Microsoft automatically deletes previously synced activity data within 30 days of its last sync to the cloud — this default applies to all three categories above. To make sure data doesn't keep re-accumulating (and that the 30-day auto-deletion keeps things minimal going forward), turn off activity-history collection:

1. On Windows: **Settings** → **Privacy & security** → **Activity history** → turn **off** "Store my activity history on this device" and, if shown, "Send my activity history to Microsoft"
2. On the dashboard: under each category (apps/services, search, browsing), leave the personalization/sync options off so new activity isn't stored to the cloud

With collection off and the categories cleared, Microsoft's 30-day auto-deletion removes any remaining synced data and nothing new is added.

### 9. Convert Your Account to a Local Account (Optional)

If you'd rather not sign in to Windows with a Microsoft account, convert your **current** account to a local one. This keeps your existing profile, files, apps, and settings — it only detaches the Microsoft account and replaces the sign-in with a local username and password.

1. **Settings** → **Accounts** → **Your info**
2. Under **Account settings**, select **Sign in with a local account instead**
3. Confirm your current Microsoft account password when prompted
4. Set a local username, password, and password hint for the same profile
5. Sign out and back in using the new local credentials

> **Note**: This converts the account in place — don't create a separate user, or you'll get a fresh empty profile instead. Do this *after* any steps that require a Microsoft account (upgrading to Pro, BitLocker key management, and the account-data cleanup above).

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

---

**Windows Version**: Windows 11 25H2
