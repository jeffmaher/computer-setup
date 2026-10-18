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
# Note: Apple doesn't guarantee defaults keys across macOS versions. The
#       README notes the version this was last tested on. If a setting
#       doesn't take effect, set it in System Settings by hand.

echo "=========================================="
echo "macOS Per-User Settings ($(whoami))"
echo "=========================================="
echo ""

echo "Running on macOS $(sw_vers -productVersion)."
echo ""
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
echo "    - Reduce transparency"
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
echo "  Keyboard"
echo "    - Window tiling shortcuts: halves on Control-Option-Command-arrows,"
echo "      quarters on Control-Option-Command-U/I/J/K"
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

# --------------------------------------------------------------------------
# Helpers
# --------------------------------------------------------------------------
# Each setting is one or more writes followed by "result". If any write in
# the group fails, it's reported as failed (with where to set it by hand)
# instead of printing success.
FAILURES=()
STEP_OK=true

w() {
    defaults write "$@" 2>/dev/null || STEP_OK=false
}

w_host() {
    defaults -currentHost write "$@" 2>/dev/null || STEP_OK=false
}

result() {
    local message=$1
    local manual=$2
    if [[ "$STEP_OK" == true ]]; then
        echo "  - $message"
    else
        echo "  ! Not applied: $message"
        FAILURES+=("$message|$manual")
    fi
    STEP_OK=true
}

# ==========================================================================
# General
# ==========================================================================
echo "General:"

w com.apple.coreservices.useractivityd ActivityAdvertisingAllowed -bool false
w com.apple.coreservices.useractivityd ActivityReceivingAllowed -bool false
result "Handoff between devices: Off" "General > AirDrop & Handoff"

w com.apple.controlcenter AirplayRecieverEnabled -bool false
result "AirPlay Receiver: Off" "General > AirDrop & Handoff"

w NSGlobalDomain AppleICUForce24HourTime -bool true
result "24-hour time: On" "General > Date & Time"

w NSGlobalDomain AppleFirstWeekday -dict gregorian -int 2
result "First day of week: Monday" "General > Language & Region"

echo ""

# ==========================================================================
# Accessibility
# ==========================================================================
# Toolbar button shapes is set by hand (see the README): macOS blocks
# Terminal from changing it.
echo "Accessibility:"

w com.apple.universalaccess differentiateWithoutColor -bool true
result "Differentiate without color: On" "Accessibility > Display"

w com.apple.universalaccess reduceTransparency -bool true
result "Reduce transparency: On" "Accessibility > Display"

echo ""

# ==========================================================================
# Appearance
# ==========================================================================
echo "Appearance:"

w NSGlobalDomain AppleShowScrollBars -string "Always"
result "Show scroll bars: Always" "Appearance"

echo ""

# ==========================================================================
# Desktop & Dock
# ==========================================================================
echo "Desktop & Dock:"

w com.apple.dock minimize-to-application -bool true
result "Minimize windows into application icon: On" "Desktop & Dock"

w com.apple.dock autohide -bool true
result "Automatically hide the Dock: On" "Desktop & Dock"

w com.apple.dock show-recents -bool false
result "Suggested and recent apps in Dock: Off" "Desktop & Dock"

w com.apple.WindowManager StandardHideDesktopIcons -bool true
result "Widgets on Desktop: Off" "Desktop & Dock > Widgets"

w com.apple.WindowManager StageManagerHideWidgets -bool true
result "Widgets in Stage Manager: Off" "Desktop & Dock > Widgets"

w NSGlobalDomain AppleWindowTabbingMode -string "always"
result "Prefer tabs when opening documents: Always" "Desktop & Dock > Windows"

w com.apple.dock expose-group-apps -bool true
result "Group windows by application: On" "Desktop & Dock > Mission Control"

w com.apple.dock wvous-br-corner -int 0
result "Bottom-right hot corner (Quick Note): Off" "Desktop & Dock > Hot Corners"

echo ""

# ==========================================================================
# Screensaver
# ==========================================================================
echo "Screensaver:"

w_host com.apple.screensaver idleTime -int 0
result "Start screen saver: Never" "Lock Screen > Start Screen Saver when inactive"

echo ""

# ==========================================================================
# Screenshots
# ==========================================================================
echo "Screenshots:"

mkdir -p "$HOME/Pictures/Screenshots"
w com.apple.screencapture location -string "$HOME/Pictures/Screenshots"
result "Screenshot location: ~/Pictures/Screenshots" "Screenshot app (Shift-Command-5) > Options > Save to"

echo ""

# ==========================================================================
# Sound
# ==========================================================================
echo "Sound:"

w com.apple.systemsound "com.apple.sound.uiaudio.enabled" -int 0
result "User interface sound effects: Off" "Sound"

w NSGlobalDomain com.apple.sound.beep.feedback -bool true
result "Volume change feedback: On" "Sound"

echo ""

# ==========================================================================
# Lock Screen
# ==========================================================================
# sysadminctl applies to the current user and prompts for this account's
# password.
echo "Lock Screen:"

sysadminctl -screenLock immediate -password - 2>/dev/null || STEP_OK=false
result "Require password after sleep or screen saver: Immediately" "Lock Screen > Require password after screen saver begins or display is turned off"

echo ""

# ==========================================================================
# Finder
# ==========================================================================
echo "Finder:"

w com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
w com.apple.finder ShowHardDrivesOnDesktop -bool false
w com.apple.finder ShowMountedServersOnDesktop -bool false
w com.apple.finder ShowRemovableMediaOnDesktop -bool false
result "Items on desktop: All hidden" "Finder > Settings > General"

w NSGlobalDomain AppleShowAllExtensions -bool true
result "Show all filename extensions: On" "Finder > Settings > Advanced"

w com.apple.finder FXEnableRemoveFromICloudDriveWarning -bool false
result "iCloud Drive removal warning: Off" "Finder > Settings > Advanced"

w com.apple.finder FXRemoveOldTrashItems -bool true
result "Remove items from Trash after 30 days: On" "Finder > Settings > Advanced"

w com.apple.finder FXDefaultSearchScope -string "SCcf"
result "Search scope: Current folder" "Finder > Settings > Advanced"

echo ""

# ==========================================================================
# Spotlight
# ==========================================================================
echo "Spotlight:"

w com.apple.Spotlight showedFTE -bool true
w com.apple.lookup.shared LookupSuggestionsDisabled -bool true
result "Spotlight suggestions and related content: Off" "Spotlight"

echo ""

# ==========================================================================
# Keyboard: window tiling shortcuts
# ==========================================================================
# Custom shortcuts for the Window > Move & Resize menu items. \033 separates
# the menu path, so these only apply to those exact menu items.
# Modifiers: ^ Control, ~ Option, @ Command.
# Arrow keys: \UF700 up, \UF701 down, \UF702 left, \UF703 right.
# Apps pick these up when they're next opened; log out to apply everywhere.
echo "Keyboard:"

TILE='\033Window\033Move & Resize\033'

w -g NSUserKeyEquivalents -dict-add \
    "${TILE}Left" '^~@\UF702' \
    "${TILE}Right" '^~@\UF703' \
    "${TILE}Top" '^~@\UF700' \
    "${TILE}Bottom" '^~@\UF701' \
    "${TILE}Top Left" '^~@u' \
    "${TILE}Top Right" '^~@i' \
    "${TILE}Bottom Left" '^~@j' \
    "${TILE}Bottom Right" '^~@k'
result "Window tiling shortcuts: Control-Option-Command-arrows (halves), -U/I/J/K (quarters)" "Keyboard > Keyboard Shortcuts > App Shortcuts"

echo ""

# ==========================================================================
# Mouse
# ==========================================================================
echo "Mouse:"

w NSGlobalDomain com.apple.swipescrolldirection -bool false
result "Natural scrolling: Off" "Mouse"

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

# ==========================================================================
# Summary
# ==========================================================================
echo ""
echo "=========================================="
if [[ ${#FAILURES[@]} -eq 0 ]]; then
    echo "COMPLETE"
    echo "=========================================="
else
    echo "COMPLETE WITH ${#FAILURES[@]} FAILURE(S)"
    echo "=========================================="
    echo ""
    echo "These weren't applied. Set them by hand in System Settings:"
    echo ""
    for f in $FAILURES; do
        echo "  - ${f%%|*}"
        echo "      ${f#*|}"
    done
fi
echo ""
echo "Some changes may require a logout or restart."
echo ""
echo "Proceed with the manual settings in the README."
echo ""
echo "Repeat this script in each of your other accounts."
echo ""
