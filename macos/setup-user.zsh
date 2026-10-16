#!/bin/zsh

# macOS Per-User Settings
# Run in EACH user account (work, personal, and optionally admin).
# Works from a standard (non-admin) account; no sudo required.
#
# Machine-wide settings (computer name, startup sound, firewall, power)
# live in setup-machine.zsh, run once from the admin account.
#
# Note: Some settings require a logout/restart to take effect.
# Note: Close System Settings before running this script to avoid conflicts.
# Note: Written for macOS 27 (Golden Gate). The defaults keys were originally
#       tested on macOS Tahoe 26, and Apple doesn't guarantee them across
#       versions. Spotlight was rebuilt in macOS 27, so its keys are the most
#       likely to have changed. If a setting doesn't take effect, set it in
#       System Settings by hand.

echo "=========================================="
echo "macOS Per-User Settings ($(whoami))"
echo "=========================================="
echo ""

OS_VERSION=$(sw_vers -productVersion)
if [[ ${OS_VERSION%%.*} -ne 27 ]]; then
    echo "Note: this script was written for macOS 27; this Mac is on $OS_VERSION."
    echo "Some settings may behave differently."
    echo ""
fi
echo "Make sure System Settings is closed before"
echo "running this script."
echo ""
echo "This script will make the following changes:"
echo ""
echo "  General"
echo "    - Disable Handoff between devices"
echo "    - Disable AirPlay Receiver"
echo "    - Enable 24-hour time format"
echo "    - Set first day of week to Monday"
echo ""
echo "  Accessibility"
echo "    - Enable differentiate without color"
echo "    - Show toolbar button shapes"
echo ""
echo "  Appearance"
echo "    - Always show scroll bars"
echo ""
echo "  Desktop & Dock"
echo "    - Minimize windows into application icon"
echo "    - Auto-hide the Dock"
echo "    - Hide suggested and recent apps in Dock"
echo "    - Disable widgets on Desktop and Stage Manager"
echo "    - Prefer tabs when opening documents"
echo "    - Group windows by application in Mission Control"
echo "    - Disable Quick Note hot corner (bottom-right)"
echo "    - Disable separate Spaces per display (all monitors switch together)"
echo ""
echo "  Screensaver"
echo "    - Disable screensaver (set to Never)"
echo ""
echo "  Screenshots"
echo "    - Save screenshots and screen recordings to ~/Pictures/Screenshots"
echo ""
echo "  Sound"
echo "    - Disable user interface sound effects (trash, screenshots, etc.)"
echo "    - Enable volume change feedback sound"
echo ""
echo "  Lock Screen"
echo "    - Require password immediately after sleep (asks for your password)"
echo ""
echo "  Finder"
echo "    - Hide all items from desktop"
echo "    - Show all filename extensions"
echo "    - Disable iCloud Drive removal warning"
echo "    - Auto-empty Trash after 30 days"
echo "    - Search the current folder by default"
echo ""
echo "  Spotlight"
echo "    - Disable suggestions and related content"
echo ""
echo "  Safari"
echo "    - Set new windows and tabs to Empty Page"
echo "    - Remove history after one month"
echo "    - Disable auto-open of safe downloads"
echo "    - Set tab layout to Compact"
echo "    - Set search engine to DuckDuckGo"
echo "    - Disable search suggestions and Safari Suggestions"
echo "    - Disable Quick Website Search and Preload Top Hit"
echo "    - Enable developer tools"
echo ""
echo "  Mouse"
echo "    - Disable natural scrolling"
echo ""
echo "  Shell"
echo "    - Add tab completion initialization to ~/.zshrc"
echo ""
echo "=========================================="
read "CONFIRM?Proceed with these changes? (y/n): "

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo ""

echo "=========================================="
echo "Applying changes..."
echo "=========================================="
echo ""

# ==========================================================================
# General
# ==========================================================================
echo "General:"

defaults write com.apple.coreservices.useractivityd ActivityAdvertisingAllowed -bool false
defaults write com.apple.coreservices.useractivityd ActivityReceivingAllowed -bool false
echo "  - Disabled Handoff between devices"

defaults write com.apple.controlcenter AirplayRecieverEnabled -bool false
echo "  - Disabled AirPlay Receiver"

defaults write NSGlobalDomain AppleICUForce24HourTime -bool true
echo "  - Enabled 24-hour time format"

defaults write NSGlobalDomain AppleFirstWeekday -dict gregorian -int 2
echo "  - Set first day of week to Monday"

echo ""

# ==========================================================================
# Accessibility
# ==========================================================================
echo "Accessibility:"

defaults write com.apple.universalaccess differentiateWithoutColor -bool true
echo "  - Enabled differentiate without color"

defaults write com.apple.universalaccess showToolbarButtonShapes -bool true
echo "  - Enabled toolbar button shapes"

echo ""

# ==========================================================================
# Appearance
# ==========================================================================
echo "Appearance:"

defaults write NSGlobalDomain AppleShowScrollBars -string "Always"
echo "  - Set scroll bars to always show"

echo ""

# ==========================================================================
# Desktop & Dock
# ==========================================================================
echo "Desktop & Dock:"

defaults write com.apple.dock minimize-to-application -bool true
echo "  - Minimize windows into application icon"

defaults write com.apple.dock autohide -bool true
echo "  - Auto-hide the Dock"

defaults write com.apple.dock show-recents -bool false
echo "  - Hid suggested and recent apps from Dock"

defaults write com.apple.WindowManager StandardHideDesktopIcons -bool true
echo "  - Disabled widgets on Desktop"

defaults write com.apple.WindowManager StageManagerHideWidgets -bool true
echo "  - Disabled widgets in Stage Manager"

defaults write NSGlobalDomain AppleWindowTabbingMode -string "always"
echo "  - Set tab preference to Always"

defaults write com.apple.dock expose-group-apps -bool true
echo "  - Enabled group windows by application"

defaults write com.apple.dock wvous-br-corner -int 0
echo "  - Disabled Quick Note hot corner (bottom-right)"

defaults write com.apple.spaces spans-displays -bool true
echo "  - Disabled separate Spaces per display (all monitors switch together)"

echo ""

# ==========================================================================
# Screensaver
# ==========================================================================
echo "Screensaver:"

defaults -currentHost write com.apple.screensaver idleTime -int 0
echo "  - Disabled screensaver (set to Never)"

echo ""

# ==========================================================================
# Screenshots
# ==========================================================================
echo "Screenshots:"

mkdir -p "$HOME/Pictures/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Pictures/Screenshots"
echo "  - Save location set to ~/Pictures/Screenshots"

echo ""

# ==========================================================================
# Sound
# ==========================================================================
echo "Sound:"

defaults write com.apple.systemsound "com.apple.sound.uiaudio.enabled" -int 0
echo "  - Disabled user interface sound effects"

defaults write NSGlobalDomain com.apple.sound.beep.feedback -bool true
echo "  - Enabled volume change feedback sound"

echo ""

# ==========================================================================
# Lock Screen
# ==========================================================================
echo "Lock Screen:"

# On recent macOS, the askForPassword defaults keys are largely ignored.
# sysadminctl is the supported route; it applies to the current user and
# prompts for this account's password. The defaults keys are kept as a
# fallback for older versions.
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0
if sysadminctl -screenLock immediate -password - 2>/dev/null; then
    echo "  - Require password immediately after sleep or screensaver"
else
    echo "  ! Could not set screen lock via sysadminctl."
    echo "    Set it manually: System Settings > Lock Screen >"
    echo "    Require password after screen saver begins or display is turned off: Immediately"
fi

echo ""

# ==========================================================================
# Finder
# ==========================================================================
echo "Finder:"

defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowMountedServersOnDesktop -bool false
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false
echo "  - Hid all items from desktop"

defaults write NSGlobalDomain AppleShowAllExtensions -bool true
echo "  - Show all filename extensions"

defaults write com.apple.finder FXEnableRemoveFromICloudDriveWarning -bool false
echo "  - Disabled iCloud Drive removal warning"

defaults write com.apple.finder FXRemoveOldTrashItems -bool true
echo "  - Auto-empty Trash after 30 days"

defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
echo "  - Set search to current folder by default"

echo ""

# ==========================================================================
# Spotlight
# ==========================================================================
echo "Spotlight:"

defaults write com.apple.Spotlight showedFTE -bool true
defaults write com.apple.lookup.shared LookupSuggestionsDisabled -bool true
echo "  - Disabled suggestions and related content"

echo ""

# ==========================================================================
# Safari
# ==========================================================================
echo "Safari:"

osascript -e 'tell application "Safari" to quit' 2>/dev/null

defaults write com.apple.Safari NewWindowBehavior -int 1
defaults write com.apple.Safari NewTabBehavior -int 1
echo "  - Set new windows and tabs to Empty Page"

defaults write com.apple.Safari HistoryAgeInDaysLimit -int 31
echo "  - Remove history after one month"

defaults write com.apple.Safari AutoOpenSafeDownloads -bool false
echo "  - Disabled auto-open of safe downloads"

defaults write com.apple.Safari ShowStandaloneTabBar -bool false
echo "  - Set tab layout to Compact"

defaults write com.apple.Safari SearchProviderShortName -string "DuckDuckGo"
echo "  - Set search engine to DuckDuckGo"

defaults write com.apple.Safari SuppressSearchSuggestions -bool true
defaults write com.apple.Safari UniversalSearchEnabled -bool false
echo "  - Disabled search engine suggestions and Safari Suggestions"

defaults write com.apple.Safari WebsiteSpecificSearchEnabled -bool false
echo "  - Disabled Quick Website Search"

defaults write com.apple.Safari PreloadTopHit -bool false
echo "  - Disabled Preload Top Hit"

defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" -bool true
echo "  - Enabled developer tools"

echo ""

# ==========================================================================
# Mouse
# ==========================================================================
echo "Mouse:"

defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
echo "  - Disabled natural scrolling"

echo ""

# ==========================================================================
# Shell (zshrc)
# ==========================================================================
echo "Shell:"

if ! grep -q "autoload -Uz compinit" "$HOME/.zshrc" 2>/dev/null; then
    cat >> "$HOME/.zshrc" << 'EOF'

# Tab completion initialization
autoload -Uz compinit
compinit
EOF
    echo "  - Added tab completion initialization to ~/.zshrc"
else
    echo "  - Tab completion initialization already exists in ~/.zshrc"
fi

echo ""

# ==========================================================================
# Restart affected applications
# ==========================================================================
echo "=========================================="
echo "Restarting Dock, Finder, and SystemUIServer..."
echo "=========================================="

killall Dock 2>/dev/null
killall Finder 2>/dev/null
killall SystemUIServer 2>/dev/null

echo "  - Done"

echo ""
echo "=========================================="
echo "COMPLETE"
echo "=========================================="
echo ""
echo "Some changes may require a logout or restart."
echo ""
echo "Verify the changes in System Settings, then"
echo "proceed with the manual settings in the README."
echo ""
echo "Repeat this script in each of your other accounts."
echo ""
echo "=========================================="
echo ""
