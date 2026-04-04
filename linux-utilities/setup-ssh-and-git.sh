#!/bin/bash

# GitHub SSH & Git Setup Script (Linux)
# Sets up single or multiple GitHub accounts
# For multi-account: personal is default everywhere, work applies only in WORK_GIT_DIR

echo "=========================================="
echo "GitHub SSH & Git Setup (Linux)"
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
read -p "Do you want to set up separate personal and work accounts? (y/n): " SETUP_WORK

SETUP_WORK_ACCOUNT=false
if [[ "$SETUP_WORK" =~ ^[Yy]$ ]]; then
    SETUP_WORK_ACCOUNT=true
fi

if [[ "$SETUP_WORK_ACCOUNT" == true ]]; then
    # Prompt for personal account details
    echo ""
    echo "Personal Account Configuration:"
    echo "--------------------------------"
    read -p "[Personal] Your name: " PERSONAL_NAME
    read -p "[Personal] Your Git email address (possibly anonymized): " PERSONAL_EMAIL
    read -p "[Personal] Your SSH email address: " PERSONAL_SSH_EMAIL

    echo ""
    # Prompt for work account details
    echo "Work Account Configuration:"
    echo "--------------------------------"
    read -p "[Work] Your name: " WORK_NAME
    read -p "[Work] Your Git email address (possibly anonymized): " WORK_EMAIL
    read -p "[Work] Your SSH email address: " WORK_SSH_EMAIL

    echo ""
    # Prompt for work directory
    read -p "Work projects directory (default: ~/code/work): " WORK_GIT_DIR_INPUT
    WORK_GIT_DIR="${WORK_GIT_DIR_INPUT:-$HOME/code/work}"
else
    # Single account prompts
    echo ""
    echo "Account Configuration:"
    echo "--------------------------------"
    read -p "Your name: " PERSONAL_NAME
    read -p "Your Git email address (possibly anonymized): " PERSONAL_EMAIL
    read -p "Your SSH email address: " PERSONAL_SSH_EMAIL
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

read -p "Proceed with setup? (y/n): " CONFIRM

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Setup cancelled."
    exit 0
fi

echo ""
echo "=========================================="
echo "Beginning Setup"
echo "=========================================="
echo ""

# Install keychain
echo "=========================================="
echo "Installing keychain..."
echo "=========================================="
sudo apt install -y keychain

# Ensure .ssh directory exists
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

# Generate key(s)
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

Host github-work
    HostName github.com
    User git
    IdentityFile $WORK_SSH_KEY
    IdentitiesOnly yes
EOF
else
    cat > "$HOME/.ssh/config" << EOF
Host github.com
    HostName github.com
    User git
    IdentityFile $PERSONAL_SSH_KEY
EOF
fi
chmod 600 "$HOME/.ssh/config"
echo "SSH config created successfully"

# Configure Git globally
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

# Add keychain configuration to .bashrc
echo ""
echo "=========================================="
echo "Configuring keychain in .bashrc..."
echo "=========================================="
if ! grep -q "keychain --eval --quiet --agents ssh" "$HOME/.bashrc" 2>/dev/null; then
    if [[ "$SETUP_WORK_ACCOUNT" == true ]]; then
        cat >> "$HOME/.bashrc" << 'EOF'

# SSH keychain - start agent without adding keys automatically
eval $(keychain --eval --quiet --agents ssh)

# Aliases to add SSH keys
alias ssh-add-personal='ssh-add ~/.ssh/id_ed25519_personal'
alias ssh-add-work='ssh-add ~/.ssh/id_ed25519_work'
EOF
    else
        cat >> "$HOME/.bashrc" << 'EOF'

# SSH keychain - start agent without adding keys automatically
eval $(keychain --eval --quiet --agents ssh)
EOF
    fi
    echo "Keychain configuration added to .bashrc"
else
    echo "Keychain configuration already exists in .bashrc"
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
    echo "   source ~/.bashrc"
    echo ""
    echo "3. Test your connections:"
    echo "   ssh -T git@github.com"
    echo "   ssh -T git@github-work"
    echo ""
    echo "4. When ready to use Git, run one or both:"
    echo "   ssh-add-personal  (for personal repos)"
    echo "   ssh-add-work      (for work repos)"
    echo "   (Each will prompt for its respective SSH key passphrase)"
else
    echo "2. Restart your terminal or run:"
    echo "   source ~/.bashrc"
    echo ""
    echo "3. Test your connection:"
    echo "   ssh -T git@github.com"
    echo ""
    echo "4. When ready to use Git, run:"
    echo "   ssh-add"
    echo "   (This will prompt for your SSH key passphrase)"
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
