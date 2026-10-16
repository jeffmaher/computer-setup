#!/bin/zsh

# Update apps and tools
#
# - uv is installed per user, so this updates the current account's copy.
# - Homebrew is owned by the admin account. From a standard account, this
#   switches to the admin account for the brew steps (asks for its password).
#
# Set ADMIN_USER to your admin account's short name, or pass it as an
# argument: zsh update-apps.zsh <admin-user>

ADMIN_USER="${1:-${ADMIN_USER:-}}"
BREW=/opt/homebrew/bin/brew

# --------------------------------------------------------------------------
# Homebrew
# --------------------------------------------------------------------------
# "brew update" refreshes Homebrew itself; "brew upgrade" updates packages.
echo "Homebrew:"

if [[ ! -x $BREW ]]; then
    echo "  - Homebrew not installed (skipped)"
elif [[ -w /opt/homebrew ]]; then
    $BREW update && $BREW upgrade
else
    if [[ -z "$ADMIN_USER" ]]; then
        read "ADMIN_USER?  Admin account short name (for brew): "
    fi
    if [[ -n "$ADMIN_USER" ]]; then
        echo "  Switching to '$ADMIN_USER' for Homebrew (enter that account's password)"
        su -l "$ADMIN_USER" -c "$BREW update && $BREW upgrade"
    else
        echo "  - No admin account given (skipped)"
    fi
fi

echo ""

# --------------------------------------------------------------------------
# uv (per user)
# --------------------------------------------------------------------------
echo "uv ($(whoami)):"

if command -v uv >/dev/null 2>&1; then
    uv self update
else
    echo "  - uv not installed in this account (skipped)"
fi
