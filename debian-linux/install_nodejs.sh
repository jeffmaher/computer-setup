set -e

# Download and install NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
export NVM_DIR="$HOME/.nvm"
\. "$NVM_DIR/nvm.sh"
\. "$NVM_DIR/bash_completion"
cat bashrc_nodejs.txt >> ~/.bashrc

# Install the latest LTS
nvm install --lts

# Restart
echo "Success! Please restart your terminal."
