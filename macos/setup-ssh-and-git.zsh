#!/bin/zsh

# GitHub Multi-Account Setup Script (macOS)
# Sets up personal and work GitHub accounts
# Personal is default everywhere, work applies only in WORK_GIT_DIR
#
# macOS-specific changes from Linux version:
# - No keychain utility (uses macOS native SSH agent with AddKeysToAgent 24h)
# - SSH keys held in agent for 24h, passphrase not persisted to Keychain
# - macOS prompts for passphrase automatically on first use; ssh-add aliases
#   are added to .zshrc as an optional convenience for manual key loading

echo "=========================================="
echo "GitHub SSH & Git Setup (macOS)"
echo "=========================================="
echo ""
echo "This script will configure your system for"
echo "GitHub authentication with SSH keys."
echo ""
echo "=========================================="
echo "Configuration Input"
echo "=========================================="
echo ""

# Ask if they want to set up multiple accounts
read "SETUP_WORK?Do you want to set up separate personal and work accounts? (y/n): "

SETUP_WORK_ACCOUNT=false
if [[ "$SETUP_WORK" =~ ^[Yy]$ ]]; then
    SETUP_WORK_ACCOUNT=true
fi

if [[ "$SETUP_WORK_ACCOUNT" == true ]]; then
    # Prompt for personal account details
    echo ""
    echo "Personal Account Configuration:"
    echo "--------------------------------"
    read "PERSONAL_NAME?[Personal] Your name: "
    read "PERSONAL_EMAIL?[Personal] Your Git email address (possibly anonymized): "
    read "PERSONAL_SSH_EMAIL?[Personal] Your SSH email address: "

    echo ""
    # Prompt for work account details
    echo "Work Account Configuration:"
    echo "--------------------------------"
    read "WORK_NAME?[Work] Your name: "
    read "WORK_EMAIL?[Work] Your Git email address (possibly anonymized): "
    read "WORK_SSH_EMAIL?[Work] Your SSH email address: "

    echo ""
    # Prompt for work directory
    read "WORK_GIT_DIR_INPUT?Work projects directory (default: ~/code/work): "
    WORK_GIT_DIR="${WORK_GIT_DIR_INPUT:-$HOME/code/work}"
else
    # Single account prompts
    echo ""
    echo "Account Configuration:"
    echo "--------------------------------"
    read "PERSONAL_NAME?Your name: "
    read "PERSONAL_EMAIL?Your Git email address (possibly anonymized): "
    read "PERSONAL_SSH_EMAIL?Your SSH email address: "
fi

# SSH key paths
if [[ "$SETUP_WORK_ACCOUNT" == true ]]; then
    PERSONAL_SSH_KEY="$HOME/.ssh/id_ed25519_personal"
    WORK_SSH_KEY="$HOME/.ssh/id_ed25519_work"
else
    PERSONAL_SSH_KEY="$HOME/.ssh/id_ed25519"
fi

echo ""
echo "=========================================="
echo "Configuration Summary"
echo "=========================================="
echo ""

if [[ "$SETUP_WORK_ACCOUNT" == true ]]; then
    echo "Personal Account:"
    echo "  Name: $PERSONAL_NAME"
    echo "  Git Email: $PERSONAL_EMAIL"
    echo "  SSH Email: $PERSONAL_SSH_EMAIL"
    echo ""
    echo "Work Account:"
    echo "  Name: $WORK_NAME"
    echo "  Git Email: $WORK_EMAIL"
    echo "  SSH Email: $WORK_SSH_EMAIL"
    echo ""
    echo "Work Directory: $WORK_GIT_DIR"
else
    echo "Account:"
    echo "  Name: $PERSONAL_NAME"
    echo "  Git Email: $PERSONAL_EMAIL"
    echo "  SSH Email: $PERSONAL_SSH_EMAIL"
fi
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
echo "=========================================="
echo "Beginning Setup"
echo "=========================================="
echo ""

# Ensure .ssh directory exists
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

# Generate personal key
echo ""
echo "=========================================="
if [[ "$SETUP_WORK_ACCOUNT" == true ]]; then
    echo "Creating Personal SSH Key"
else
    echo "Creating SSH Key"
fi
echo "=========================================="
ssh-keygen -t ed25519 -C "$PERSONAL_SSH_EMAIL" -f "$PERSONAL_SSH_KEY"

# Generate work key if needed
if [[ "$SETUP_WORK_ACCOUNT" == true ]]; then
    echo ""
    echo "=========================================="
    echo "Creating Work SSH Key"
    echo "=========================================="
    ssh-keygen -t ed25519 -C "$WORK_SSH_EMAIL" -f "$WORK_SSH_KEY"
fi

# Create SSH config
# Uses AddKeysToAgent with 24h timeout (passphrase held in memory only)
# No UseKeychain — passphrase is NOT persisted to macOS Keychain
echo ""
echo "=========================================="
echo "Setting up SSH config..."
echo "=========================================="
if [[ "$SETUP_WORK_ACCOUNT" == true ]]; then
    cat > "$HOME/.ssh/config" << EOF
Host github.com
    HostName github.com
    User git
    IdentityFile $PERSONAL_SSH_KEY
    IdentitiesOnly yes
    AddKeysToAgent 24h

Host github-work
    HostName github.com
    User git
    IdentityFile $WORK_SSH_KEY
    IdentitiesOnly yes
    AddKeysToAgent 24h
EOF
else
    cat > "$HOME/.ssh/config" << EOF
Host *
    AddKeysToAgent 24h
EOF
fi
chmod 600 "$HOME/.ssh/config"
echo "SSH config created successfully"

# Configure Git globally (personal as default)
echo ""
echo "=========================================="
echo "Configuring Git..."
echo "=========================================="
git config --global user.name "$PERSONAL_NAME"
git config --global user.email "$PERSONAL_EMAIL"
if [[ "$SETUP_WORK_ACCOUNT" == true ]]; then
    git config --global core.sshCommand "ssh -i $PERSONAL_SSH_KEY"
fi
echo "Global Git config set"

# Set up work directory and config if needed
if [[ "$SETUP_WORK_ACCOUNT" == true ]]; then
    # Create work projects directory
    echo ""
    echo "=========================================="
    echo "Creating work directory..."
    echo "=========================================="
    mkdir -p "$WORK_GIT_DIR"
    echo "Created $WORK_GIT_DIR"

    # Add conditional include
    echo ""
    echo "=========================================="
    echo "Setting up Git config for work directory..."
    echo "=========================================="
    git config --global "includeIf.gitdir:$WORK_GIT_DIR/".path "$WORK_GIT_DIR/.gitconfig"

    # Create work config in work directory
    cat > "$WORK_GIT_DIR/.gitconfig" << EOF
[user]
    name = $WORK_NAME
    email = $WORK_EMAIL
[core]
    sshCommand = ssh -i $WORK_SSH_KEY
EOF
    echo "Work Git config created at $WORK_GIT_DIR/.gitconfig"
fi

# Add optional ssh-add aliases to .zshrc (multi-account only)
# macOS SSH agent handles key loading automatically via AddKeysToAgent,
# but these aliases are convenient if you prefer to pre-load keys manually
if [[ "$SETUP_WORK_ACCOUNT" == true ]]; then
    echo ""
    echo "=========================================="
    echo "Adding SSH aliases to .zshrc..."
    echo "=========================================="
    if ! grep -q "ssh-add-personal" "$HOME/.zshrc" 2>/dev/null; then
        cat >> "$HOME/.zshrc" << 'EOF'

# SSH key aliases (optional — macOS prompts automatically on first use)
alias ssh-add-personal='ssh-add ~/.ssh/id_ed25519_personal'
alias ssh-add-work='ssh-add ~/.ssh/id_ed25519_work'
EOF
        echo "SSH aliases added to .zshrc"
    else
        echo "SSH aliases already exist in .zshrc"
    fi
fi

echo ""
echo "=========================================="
echo "SETUP COMPLETE!"
echo "=========================================="
echo ""
echo "=========================================="
if [[ "$SETUP_WORK_ACCOUNT" == true ]]; then
    echo "SSH KEYS TO ADD TO GITHUB"
else
    echo "SSH KEY TO ADD TO GITHUB"
fi
echo "=========================================="
echo ""

if [[ "$SETUP_WORK_ACCOUNT" == true ]]; then
    echo "Personal Account ($PERSONAL_SSH_EMAIL):"
    echo "----------------------------------------"
    cat "$PERSONAL_SSH_KEY.pub"
    echo ""
    echo "Work Account ($WORK_SSH_EMAIL):"
    echo "----------------------------------------"
    cat "$WORK_SSH_KEY.pub"
else
    echo "Public Key ($PERSONAL_SSH_EMAIL):"
    echo "----------------------------------------"
    cat "$PERSONAL_SSH_KEY.pub"
fi

echo ""
echo "=========================================="
echo "NEXT STEPS"
echo "=========================================="
echo ""
echo "1. Add the SSH key above to your GitHub account"
echo "   - Go to GitHub Settings → SSH and GPG keys → New SSH key"
echo ""

if [[ "$SETUP_WORK_ACCOUNT" == true ]]; then
    echo "2. Restart your terminal or run:"
    echo "   source ~/.zshrc"
    echo ""
    echo "3. Test your connections:"
    echo "   ssh -T git@github.com"
    echo "   ssh -T git@github-work"
    echo ""
    echo "   (You will be prompted for your passphrase on first use."
    echo "    It will be cached for 24 hours, then required again.)"
    echo ""
    echo "   Optionally, you can pre-load keys manually:"
    echo "   ssh-add-personal  (for personal repos)"
    echo "   ssh-add-work      (for work repos)"
else
    echo "2. Test your connection:"
    echo "   ssh -T git@github.com"
    echo ""
    echo "   (You will be prompted for your passphrase on first use."
    echo "    It will be cached for 24 hours, then required again.)"
    echo ""
    echo "   Optionally, you can pre-load your key manually:"
    echo "   ssh-add"
fi
echo ""
echo "=========================================="
echo "USAGE"
echo "=========================================="
echo ""

if [[ "$SETUP_WORK_ACCOUNT" == true ]]; then
    echo "Personal repos: Clone anywhere outside $WORK_GIT_DIR"
    echo "  Example: git clone git@github.com:username/my-repo.git"
    echo ""
    echo "Work repos: Clone to $WORK_GIT_DIR"
    echo "  Example: cd $WORK_GIT_DIR && git clone git@github.com:company/work-repo.git"
    echo "  Or use: git clone git@github-work:company/work-repo.git $WORK_GIT_DIR/work-repo"
else
    echo "Clone repos anywhere:"
    echo "  Example: git clone git@github.com:username/my-repo.git"
fi

echo ""
echo "=========================================="
echo ""
