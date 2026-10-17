#!/bin/zsh

# GitHub SSH & Git Setup (macOS)
# Sets up one git identity and SSH key for the current macOS account.
# Run it in each account that needs git (work and personal), entering that
# account's details.
#
# - SSH key is held in the macOS SSH agent for 24h (AddKeysToAgent 24h)
# - Passphrase is not saved to the Keychain; macOS prompts on first use

SSH_KEY="$HOME/.ssh/id_ed25519"
SSH_CONFIG="$HOME/.ssh/config"

echo "=========================================="
echo "GitHub SSH & Git Setup ($(whoami))"
echo "=========================================="
echo ""

read "GIT_NAME?Your name: "
read "GIT_EMAIL?Your Git email address (possibly anonymized): "
read "SSH_EMAIL?Your SSH key email address (default: $GIT_EMAIL): "
SSH_EMAIL="${SSH_EMAIL:-$GIT_EMAIL}"

echo ""
echo "=========================================="
echo "Configuration Summary"
echo "=========================================="
echo ""
echo "  Name:      $GIT_NAME"
echo "  Git email: $GIT_EMAIL"
echo "  SSH email: $SSH_EMAIL"
echo "  SSH key:   $SSH_KEY"
echo ""
echo "SSH key agent timeout: 24 hours"
echo "(Passphrase required after each reboot or after 24h)"
echo ""

read "CONFIRM?Proceed with setup? (y/n): "

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Setup cancelled."
    exit 0
fi

echo ""

# --------------------------------------------------------------------------
# SSH key
# --------------------------------------------------------------------------
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

echo "=========================================="
echo "Creating SSH Key"
echo "=========================================="

if [[ -f "$SSH_KEY" ]]; then
    echo "An SSH key already exists at $SSH_KEY; keeping it."
else
    ssh-keygen -t ed25519 -C "$SSH_EMAIL" -f "$SSH_KEY"
fi

# --------------------------------------------------------------------------
# SSH config
# --------------------------------------------------------------------------
# AddKeysToAgent holds the key in memory for 24h. No UseKeychain, so the
# passphrase is never saved to the macOS Keychain.
echo ""
echo "=========================================="
echo "Setting up SSH config..."
echo "=========================================="

if grep -q "AddKeysToAgent" "$SSH_CONFIG" 2>/dev/null; then
    echo "SSH config already has AddKeysToAgent; leaving it unchanged."
else
    cat >> "$SSH_CONFIG" << EOF
Host *
    AddKeysToAgent 24h
EOF
    echo "SSH config updated"
fi
chmod 600 "$SSH_CONFIG"

# --------------------------------------------------------------------------
# Git
# --------------------------------------------------------------------------
echo ""
echo "=========================================="
echo "Configuring Git..."
echo "=========================================="

git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
echo "Global Git config set"

# --------------------------------------------------------------------------
# Next steps
# --------------------------------------------------------------------------
echo ""
echo "=========================================="
echo "SETUP COMPLETE!"
echo "=========================================="
echo ""
echo "Public key ($SSH_EMAIL):"
echo "----------------------------------------"
cat "$SSH_KEY.pub"
echo ""
echo "=========================================="
echo "NEXT STEPS"
echo "=========================================="
echo ""
echo "1. Add the SSH key above to your GitHub account"
echo "   - Go to GitHub Settings → SSH and GPG keys → New SSH key"
echo ""
echo "2. Test your connection:"
echo "   ssh -T git@github.com"
echo ""
echo "   (You will be prompted for your passphrase on first use."
echo "    It will be cached for 24 hours, then required again.)"
echo ""
