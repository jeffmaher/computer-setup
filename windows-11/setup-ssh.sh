#!/bin/bash

# Setup configuration values
PERSONAL_GIT_NAME=""
PERSONAL_SSH_EMAIL=""
PERSONAL_GIT_EMAIL=""
PERSONAL_SUFFIX="personal"

WORK_GIT_NAME=""
WORK_SSH_EMAIL=""
WORK_GIT_EMAIL=""
WORK_SUFFIX="work"

# Install keychain
echo "Installing keychain..."
sudo apt install -y keychain

# Generate keys (you'll be prompted for passwords)
echo "Creating personal SSH key..."
ssh-keygen -t ed25519 -C "$PERSONAL_SSH_EMAIL" -f ~/.ssh/id_ed25519_$PERSONAL_SUFFIX

echo "Creating work SSH key..."
ssh-keygen -t ed25519 -C "$WORK_SSH_EMAIL" -f ~/.ssh/id_ed25519_$WORK_SUFFIX

# Create SSH config
cat > ~/.ssh/config << 'EOF'
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_$PERSONAL_SUFFIX

Host github-bw
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_$WORK_SUFFIX
EOF

# Configure Git globally (personal as default)
git config --global user.name "$PERSONAL_GIT_NAME"
git config --global user.email "$PERSONAL_GIT_EMAIL"
git config --global core.sshCommand "ssh -i ~/.ssh/id_ed25519_$PERSONAL_SUFFIX"

# Create work projects directory
mkdir -p ~/code/$WORK_SUFFIX

# Add conditional include
git config --global includeIf.gitdir:~/code/$WORK_SUFFIX/.path ~/code/$WORK_SUFFIX/.gitconfig

# Create work config in work directory
cat > ~/code/$WORK_SUFFIX/.gitconfig << 'EOF'
[user]
    name = $WORK_GIT_NAME
    email = $WORK_GIT_EMAIL
[core]
    sshCommand = ssh -i ~/.ssh/id_ed25519_$WORK_SUFFIX
EOF

# Add keychain configuration to .bashrc
sudo apt install keychain -y
echo "Configuring keychain in .bashrc..."
if ! grep -q "keychain --eval --quiet --agents ssh" ~/.bashrc; then
    cat >> ~/.bashrc << 'EOF'

# SSH keychain - start agent without adding keys automatically
eval $(keychain --eval --quiet --agents ssh)
alias add-ssh-personal="ssh-add ~/.ssh/id_ed25519_$PERSONAL_SUFFIX"
alias add-ssh-work="ssh-add ~/.ssh/id_ed25519_$WORK_SUFFIX"
EOF
    echo "Keychain configuration added to .bashrc"
else
    echo "Keychain configuration already exists in .bashrc"
fi

echo ""
echo "Setup complete! Add these SSH keys to GitHub:"
echo ""
echo "Personal (jeff@pressbutton.net) key:"
cat ~/.ssh/id_ed25519_$PERSONAL_SUFFIX.pub
echo ""
echo "Work (jeff@bloomworks.digital) key:"
cat ~/.ssh/id_ed25519_$WORK_SUFFIX.pub
echo ""
echo "Next steps:"
echo "1. Add the SSH keys above to your respective GitHub accounts"
echo "2. Restart your terminal or run: source ~/.bashrc"
echo "3. When ready to use Git, run: ssh-add ~/.ssh/id_ed25519_$PERSONAL_SUFFIX && ssh-add ~/.ssh/id_ed25519_$WORK_SUFFIX"
echo "   (Or SSH will prompt you automatically on first use)"