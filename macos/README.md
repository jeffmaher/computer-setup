# First Time Setup

Get through all the setup screens, entering essentials (user account, Wi-Fi) and skipping optional steps (Apple Account, Touch ID, Apple Intelligence, Siri) since they're configured later in this guide.

# Name your computer

This controls what your computer shows up as on networks and Bluetooth. 

Go to Settings > General > About and change the name of your computer. Then, restart.

# Settings

Many of the settings below can be applied automatically by running `setup-macos-defaults.zsh`. Close System Settings first, then:

```
zsh setup-macos-defaults.zsh
```

The script will show you everything it plans to change and ask for confirmation before proceeding. It will also display each change as it's applied.

## Automatically Configured

**ℹ️ These are configured by `setup-macos-defaults.zsh`. You don't need to change them manually, but they're listed here so you know what was set.**

### Network

- Firewall: On

### Battery

- Wake for network access: Never

### General

- Autofill & Passkeys
	- AutoFill Passwords and Passkeys: Off
	- AutoFill From: Off
- Airdrop & Handoff
	- Allow Handoff between this Mac and your iCloud devices: Off
	- Airplay Receiver: Off
- Date & Time
	- 24-hour time: On
- Language & Region
	- First day of week: Monday

### Accessibility

- Display
	- Differentiate without color: On
	- Show toolbar button shapes: On

### Appearance

- Show scroll bars: Always

### Desktop & Dock

- Minimize windows into application icon: On
- Automatically hide and show the Dock: On
- Show suggested and recent apps in Dock: Off
- Show Widgets: (unselect both "On Desktop" and "In Stage Manager")
- iPhone Widgets: Off
- Prefer tabs when opening documents: Always
- Group windows by application: On

### Screensaver

- Start screen saver: Never

### Sound

- Play sound on startup: Off
- Play user interface sound effects: Off
- Play feedback when volume is changed: On

### Lock Screen

- Require password after screen saver begins or display is turned off: Immediately

### Finder

- General
	- Show these items on the desktop: (All off)
- Sidebar, turn off:
	- Shared
	- Applications
	- Desktop
	- iCloud Drive
	- AirDrop
- Advanced
	- Show all filename extensions: On
	- Show warning before removing from iCloud Drive: Off
	- Remove items from the Trash after 30 days: On
	- When performing a search: Search the current folder

### Spotlight

- Show related content: Off
- Help Apple Improve Searches: Off
- Results from Apps: turn Off all except:
	- Calculator
	- Contacts
	- Dictionary
	- Shortcuts
	- System Settings

### Safari

- General
	- New windows open with: Empty Page
	- New tabs open with: Empty Page
	- Remove history items: After one month
	- Open "safe" files after downloading: Unchecked
- Tabs
	- Tab layout: Compact
- Autofill: Uncheck all
- Search
	- Search engine: DuckDuckGo
	- Smart Search field
		- Include search engine suggestions: Unchecked
		- Include Safari Suggestions: Unchecked
		- Enable Quick Website Search: Unchecked
		- Preload Top Hit in the background: Unchecked
		- Show Start Page: Unchecked
- Security
	- Non-secure site connections
		- Warn before connecting to a website over HTTP: Checked
- Advanced
	- Show features for web developers: Checked

### Mouse

- Natural scrolling: Off

## Manually Configured

These cannot be automated and must be configured by hand in System Settings.

### Apple Account

- Sign-in
- Media & Purchases
	- Use Touch ID for Purchases: On

### Wifi

If you're using Wifi, add the networks you use regularly. If you have a hotspot (like with your phone), go to the settings for that connection and enable "Low Power Mode" so that it doesn't do big things like download updates while you're using it.

### Bluetooth

Pair any devices you want paired.

### Apple Intelligence & Siri

- Apple Intelligence: On
- Siri: Off

### Appearance

- Appearance: Auto

### Displays

- If you're using multiple displays, arrange these accordingly using "Arrange" and, if on a laptop, set "Use as" to "Main Display"
- Advanced
	- Turn  off (if not using):
		- Allow your pointer and keyboard to move between any nearby Mac or iPad
		- Push through the edge of a display to connect a nearby Mac or iPad
- Night Shift
	- Schedule: Sunset to Sunrise

### Menu Bar

- Weather: On

### Sound

- Choose your external devices for Output and Input, both when plugged and unplugged from your dock/monitor
- Alert sound: Funky

### Focus

- Do Not Disturb
	- Set a schedule:
		1. Add a schedule
		1. Time-based
		1. Start: 21:30
		1. End: 8:00
		1. Days: All
	- Allowed People: (If you have contacts synced, anyone you want to be able to get through)

### Lock Screen

- Turn display off on battery when inactive: For 3 minutes
- Turn display off on power adapter when inactive: For 10 minutes

### Touch ID & Password

Add your fingerprints

### iCloud

- Saved to iCloud > See all...
	- Turn off:
		- Photos
		- iCloud Drive
		- Passwords & Keychain
		- Notes
		- iCloud Mail
		- Contacts
		- iCloud Calendar
		- Reminders
		- News
		- Stocks
		- Home
		- Freeform
		- Image Playground
		- Journal
	- Turn on:
		- Messages in iCloud, keep messages for 30 days
		- Safari
		- Wallet
		- Facetime
		- Maps
		- Siri
		- Shortcuts
- Advanced Data Protection: On
	1. Set up a recovery method (recovery contact or recovery key) first
	1. Enter your recovery code

### Trackpad

- Tracking speed: 7

### Keyboard

In the shortcuts:

- Windows
	- General: 
		- Fill: CTRL + OPTION + CMD + M
	- Halves:
		- Tile Left Half: CTRL + OPTION + CMD + LEFT ARROW
		- Tile Right Half: CTRL + OPTION + CMD + RIGHT ARROW
		- Tile Top Half: (none)
		- Tile Bottom Half: (none)
	- Quarters
		- Tile Top Left Quarter: CTRL + OPTION + CMD + U
		- Tile Top Right Quarter: CTRL + OPTION + CMD + I
		- Tile Bottom Left Quarter: CTRL + OPTION + CMD + J
		- Tile Bottom Right Quarter: CTRL + OPTION + CMD + K

### Mouse

- Tracking speed: 5
- Scrolling speed: 6

# Foundational Apps

Install third-party tools that you use to do basic things:

- Web browsers
- Password Manager
- Storage apps
- Device controllers (like for keyboards, cameras, etc.)

# Setup Spaces for Work and Personal

1. Add all apps you use frequently to the dock
1. Create two Spaces (one for work and one for personal)
1. Secondary click (or Ctrl+click) on each dock icon, and choose which workspace you want each to appear if you only use it within one context ("None" if used for both)
1. Secondary click (or Ctrl+click) the desktop, choose Change Wallpaper
	1. Turn off "Show on all Spaces"
	1. Set a colour or wallpaper
	1. Do this for your other space with a different colour or wallpaper

# Setup SSH and GitHub

In this directory, there is a `setup-ssh-and-git-macos.zsh` script. Run that to setup work and personal SSH keys and GitHub configurations.

# Safari Extension

After the automated Safari settings have been applied, install your password manager's browser extension.
