# macOS Setup

Written for macOS 27 (Golden Gate).

## How this setup is organized

This Mac uses three accounts:

- **Admin** account, used only to install software and change machine-wide settings.
- **Work** account (standard user), for everything work-related.
- **Personal** account (standard user), for everything personal.

Keeping work and personal in separate standard accounts means code, browser sessions, and credentials in one can't be read from the other, and nothing you run day to day has admin rights.

The scripts are split the same way:

| Script | Run from | How often |
| --- | --- | --- |
| `setup-machine.zsh` | Admin account | Once per Mac |
| `setup-user.zsh` | Each account | Once per account |
| `setup-ssh-and-git.zsh` | Work and personal accounts | Once per account |

Clone this repo separately in each account rather than into a shared folder. A shared, writable copy could be edited from one account and then run from the admin account.

# 1. First Time Setup

Get through all the setup screens, entering essentials (user account, Wi-Fi) and skipping optional steps (Apple Account, Touch ID, Apple Intelligence, Siri) since they're configured later in this guide.

When asked about FileVault, choose to create a recovery key rather than letting your iCloud account unlock the disk, and save the key in your password manager.

The account you create during setup is an admin account. Use it as your **admin** account: give it a name like "Admin" and a strong password stored in your password manager.

# 2. Create the work and personal accounts

From the admin account, go to System Settings > Users & Groups > Add User, and create:

- A **Standard** account for work
- A **Standard** account for personal

Make sure each account can unlock FileVault at startup. Accounts created by an admin normally can, and you can confirm in Terminal with:

```
sysadminctl -secureTokenStatus <account-short-name>
```

It should report that the secure token is enabled.

# 3. Machine-level setup (admin account)

Run this once, from the admin account:

```
zsh setup-machine.zsh
```

The script shows what it will change, asks for confirmation, and reports any step that fails.

## Automatically configured

**ℹ️ These are configured by `setup-machine.zsh` and apply to every account.**

- Computer name (optional prompt; also sets the network host name)
- Startup sound: Off
- Firewall: On
- Wake for network access: Never
- Turn display off on battery when inactive: 3 minutes
- Turn display off on power adapter when inactive: 10 minutes
- Command Line Tools (compilers and git), if not already installed. The script opens Apple's installer and waits for you to finish it.

## Manually configured

### Software Update

System Settings > General > Software Update > Automatic Updates (info button):

- Keep "Install Security Responses and system files" On.
- Decide whether to install macOS updates automatically. If work checks the OS version for compliance, don't let updates lag for long.
- Beta Updates: Off

### Wi-Fi and Bluetooth

Add the Wi-Fi networks you use regularly and pair Bluetooth devices. These are generally shared across accounts, so doing it once is usually enough. If you have a hotspot (like with your phone), go to the settings for that connection and enable "Low Power Mode" so that it doesn't do big things like download updates while you're using it.

### Touch ID

Fingerprints belong to individual accounts, and the Mac can only store a limited number in total. Decide which fingers go to which account, then add them from within each account (step 4).

# 4. Per-account setup (work and personal accounts)

Log into each account and do everything in this section. Optionally run `setup-user.zsh` in the admin account too, so it's comfortable to use.

## Settings

Close System Settings first, then:

```
zsh setup-user.zsh
```

The script shows everything it plans to change, asks for confirmation, and displays each change as it's applied. It doesn't need admin rights.

### Automatically configured

**ℹ️ These are configured by `setup-user.zsh`. You don't need to change them manually, but they're listed here so you know what was set.**

#### General

- Airdrop & Handoff
	- Allow Handoff between this Mac and your iCloud devices: Off
	- Airplay Receiver: Off
- Date & Time
	- 24-hour time: On
- Language & Region
	- First day of week: Monday

#### Accessibility

- Display
	- Differentiate without color: On
	- Show toolbar button shapes: On
	- Reduce transparency: On

#### Appearance

- Show scroll bars: Always

#### Desktop & Dock

- Minimize windows into application icon: On
- Automatically hide and show the Dock: On
- Show suggested and recent apps in Dock: Off
- Show Widgets: (unselect both "On Desktop" and "In Stage Manager")
- Prefer tabs when opening documents: Always
- Group windows by application: On
- Hot Corners > Bottom Right: Off (disables Quick Note)
- Displays have separate Spaces: Off (all monitors switch together, requires logout)

#### Screensaver

- Start screen saver: Never

#### Screenshots

- Save location: ~/Pictures/Screenshots

#### Sound

- Play user interface sound effects: Off
- Play feedback when volume is changed: On

#### Lock Screen

- Require password after screen saver begins or display is turned off: Immediately (the script asks for your account password to set this)

#### Finder

- General
	- Show these items on the desktop: (All off)
- Advanced
	- Show all filename extensions: On
	- Show warning before removing from iCloud Drive: Off
	- Remove items from the Trash after 30 days: On
	- When performing a search: Search the current folder

#### Spotlight

- Show related content: Off

#### Safari

- General
	- New windows open with: Empty Page
	- New tabs open with: Empty Page
	- Remove history items: After one month
	- Open "safe" files after downloading: Unchecked
- Tabs
	- Tab layout: Compact
- Search
	- Search engine: DuckDuckGo
	- Smart Search field
		- Include search engine suggestions: Unchecked
		- Include Safari Suggestions: Unchecked
		- Enable Quick Website Search: Unchecked
		- Preload Top Hit in the background: Unchecked
- Advanced
	- Show features for web developers: Checked

#### Mouse

- Natural scrolling: Off

#### Shell

- Tab completion initialization added to ~/.zshrc (enables completions for tools like uv, git, etc.)

### Manually configured

These cannot be automated and must be configured by hand in System Settings, in each account.

#### Apple Account

Sign in with the Apple Account that belongs to this context (for example, your personal Apple Account only in the personal account).

- Media & Purchases
	- Use Touch ID for Purchases: On

#### iCloud

In accounts signed into an Apple Account:

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
	1. Set up a recovery contact or recovery key first (System Settings > your name > Sign-In & Security > Account Recovery). This is your Apple Account's recovery key, not the FileVault one. Save it in your password manager.
	1. Turn on Advanced Data Protection; it asks you to confirm the recovery method

#### Siri

Turning Siri on involves confirmation and setup prompts, so it's done by hand.

- System Settings > Siri
	- Turn on Siri, then click "Try Siri AI (Beta)" to use the macOS 27 version
	- Allow Siri when locked: Off
- Apple Intelligence: On (where available)

#### Appearance

- Appearance: Auto

#### Displays

- True Tone: Off
- If you're using multiple displays, arrange these accordingly using "Arrange" and, if on a laptop, set "Use as" to "Main Display"
- Advanced
	- Turn off (if not using):
		- Allow your pointer and keyboard to move between any nearby Mac or iPad
		- Push through the edge of a display to connect a nearby Mac or iPad
- Night Shift
	- Schedule: Sunset to Sunrise

#### Sound

- Choose your external devices for Output and Input, both when plugged and unplugged from your dock/monitor
- Alert sound: Funky

#### Focus

- Do Not Disturb
	- Set a schedule:
		1. Add a schedule
		1. Time-based
		1. Start: 21:30
		1. End: 8:00
		1. Days: All
	- Allowed People: (If you have contacts synced, anyone you want to be able to get through)

#### Touch ID & Password

Add this account's fingerprints (see the plan from step 3).

#### Login Items & Extensions

Review System Settings > General > Login Items & Extensions and turn off anything you don't need.

#### Trackpad

- Tracking speed: 7

#### Keyboard

- Disable all native window tiling shortcuts:
	- System Settings > Keyboard > Keyboard Shortcuts > Windows
	- Uncheck everything under General, Halves, and Quarters

#### Mouse

- Tracking speed: 5
- Scrolling speed: 6

#### Finder

- Sidebar, turn off:
	- Shared
	- Applications
	- Desktop
	- iCloud Drive
	- AirDrop

#### Spotlight

Spotlight was rebuilt in macOS 27, so these options may be named or arranged differently.

- Help Apple Improve Searches: Off
- Results from Apps: turn Off all except:
	- Calculator
	- Contacts
	- Dictionary
	- Shortcuts
	- System Settings

#### Safari

- Tabs
	- Show color in tab bar: Unchecked
	- Organize Tabs: Show Related Tabs (suggests groupings instead of rearranging tabs automatically)
- Search
	- Show Start Page: Unchecked
- Security
	- Non-secure site connections
		- Warn before connecting to a website over HTTP: Checked

## SSH and GitHub

Run the SSH and Git script in each account that uses git:

```
zsh setup-ssh-and-git.zsh
```

It sets up one git identity and SSH key for the account you run it in:

- In the **work** account, enter your work name and email.
- In the **personal** account, enter your personal details.

This keeps your work SSH key out of the personal account's home folder, and vice versa. If the account already has an SSH key, the script keeps it instead of creating a new one.

## Apps

Install the apps each account needs: web browsers, password manager, storage apps, and device controllers (like for keyboards, cameras, etc.).

Installing into `/Applications` asks for the admin account's name and password. To keep an app to just one account, install it into `~/Applications` instead.

### Window Tiling (Rectangle)

Install [Rectangle](https://rectangleapp.com/) for window tiling. It intercepts shortcuts at a level that prevents apps from overriding them.

Shortcuts:

- Fill: CTRL + OPTION + M
- Left Half: CTRL + OPTION + LEFT ARROW
- Right Half: CTRL + OPTION + RIGHT ARROW
- Top Half: CTRL + OPTION + UP ARROW
- Bottom Half: CTRL + OPTION + DOWN ARROW
- Top Left Quarter: CTRL + OPTION + U
- Top Right Quarter: CTRL + OPTION + I
- Bottom Left Quarter: CTRL + OPTION + J
- Bottom Right Quarter: CTRL + OPTION + K

# Day-to-day use

## Switching accounts

Turn on Fast User Switching to switch accounts from the menu bar: System Settings > Control Center > Fast User Switching > Show in Menu Bar.

Both accounts keep running when you switch, but you won't see notifications from the account you're not in.

## Admin tasks from a standard account

- **Installing apps or changing locked settings:** macOS asks for the admin account's name and password.
- **Terminal commands that need sudo:** run `su <admin-account>` in that Terminal window first, then run the command.
