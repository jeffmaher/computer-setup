#!/bin/zsh

# macOS Machine-Level Setup
# Run ONCE per Mac, from the ADMIN account.
#
# These settings apply to the whole machine (every user account), so they
# don't need to be repeated in your work or personal accounts.
#
# Per-user settings live in setup-user.zsh, which you run in each account.
#
# Written for macOS 27 (Golden Gate).

SCRIPT_DIR="${0:A:h}"
DNS_PROFILE="$SCRIPT_DIR/canadianshield-private-https.mobileconfig"
FAILURES=()

# --------------------------------------------------------------------------
# Preconditions
# --------------------------------------------------------------------------
if ! id -Gn | grep -qw admin; then
    echo "This script must be run from an admin account."
    echo "Log into your admin account (or run: su <admin-user>) and try again."
    exit 1
fi

echo "=========================================="
echo "macOS Machine-Level Setup"
echo "=========================================="
echo ""

OS_VERSION=$(sw_vers -productVersion)
if [[ ${OS_VERSION%%.*} -ne 27 ]]; then
    echo "Note: this script was written for macOS 27; this Mac is on $OS_VERSION."
    echo "Some settings may behave differently."
    echo ""
fi
echo "This script will make the following machine-wide changes:"
echo ""
echo "  System"
echo "    - Set computer name (optional)"
echo "    - Disable startup sound"
echo "    - Enable firewall"
echo ""
echo "  Power"
echo "    - Disable wake for network access"
echo "    - Turn display off after 3 min on battery, 10 min on power adapter"
echo ""
echo "  Network"
echo "    - Queue Canadian Shield encrypted DNS profile for approval"
echo ""
echo "  Software"
echo "    - Install Homebrew (if missing) and shared command-line tools"
echo "    - Install Rosetta 2 (optional, asks first)"
echo ""
echo "=========================================="
read "CONFIRM?Proceed with these changes? (y/n): "

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo "Admin privileges are required."
if ! sudo -v; then
    echo "Could not obtain admin privileges. Exiting."
    exit 1
fi

# Report each step honestly instead of printing success unconditionally
report() {
    local exit_code=$1
    local message=$2
    if [[ $exit_code -eq 0 ]]; then
        echo "  - $message"
    else
        echo "  ! FAILED: $message"
        FAILURES+=("$message")
    fi
}

echo ""
echo "=========================================="
echo "Applying changes..."
echo "=========================================="
echo ""

# ==========================================================================
# Computer name
# ==========================================================================
echo "Computer name:"
echo "  Current: $(scutil --get ComputerName 2>/dev/null)"
read "NEW_NAME?  New name (leave blank to keep current): "

if [[ -n "$NEW_NAME" ]]; then
    # LocalHostName/HostName can't contain spaces or most punctuation
    HOST_NAME=$(echo "$NEW_NAME" | tr ' ' '-' | tr -cd '[:alnum:]-')
    sudo scutil --set ComputerName "$NEW_NAME" && \
    sudo scutil --set LocalHostName "$HOST_NAME" && \
    sudo scutil --set HostName "$HOST_NAME"
    report $? "Set computer name to '$NEW_NAME' (host name: $HOST_NAME)"
else
    echo "  - Kept current name"
fi

echo ""

# ==========================================================================
# Sound
# ==========================================================================
echo "Sound:"

sudo nvram StartupMute=%01
report $? "Disabled startup sound"

echo ""

# ==========================================================================
# Firewall
# ==========================================================================
echo "Firewall:"

FW=/usr/libexec/ApplicationFirewall/socketfilterfw
sudo $FW --setglobalstate on >/dev/null
$FW --getglobalstate | grep -qi "enabled"
report $? "Enabled firewall"

echo ""

# ==========================================================================
# Power
# ==========================================================================
echo "Power:"

sudo pmset -a womp 0
report $? "Disabled wake for network access"

sudo pmset -b displaysleep 3
report $? "Display off after 3 minutes on battery"

sudo pmset -c displaysleep 10
report $? "Display off after 10 minutes on power adapter"

echo ""


# ==========================================================================
# Summary
# ==========================================================================
echo "=========================================="
if [[ ${#FAILURES[@]} -eq 0 ]]; then
    echo "COMPLETE"
else
    echo "COMPLETE WITH ${#FAILURES[@]} FAILURE(S):"
    for f in $FAILURES; do
        echo "  - $f"
    done
fi
echo "=========================================="
echo ""
echo "Next steps:"
echo "  - Approve the DNS profile in System Settings (if queued)"
echo "  - Finish the manual machine-level settings in the README"
echo "  - Log into each user account and run setup-user.zsh"
echo "  - In each account, run setup-ssh-and-git.zsh (single-account mode)"
echo ""
echo "A restart is recommended for the computer name to show everywhere."
echo ""
