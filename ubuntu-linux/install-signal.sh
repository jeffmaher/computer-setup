set -e

# --- Debian Package ---
# NOTE: These instructions only work for 64-bit Debian-based
# Linux distributions such as Ubuntu, Mint etc.

# 1. Install our official public software signing key:
KEYRING_FILE_PATH=/var/tmp/signal-desktop-keyring.gpg
wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > $KEYRING_FILE_PATH;
cat $KEYRING_FILE_PATH | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null

# 2. Add our repository to your list of repositories:
echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' | sudo tee /etc/apt/sources.list.d/signal-xenial.list

# 3. Update your package database and install Signal:
sudo apt update && sudo apt install signal-desktop -y

# --- Flatpak Install ---
# flatpak install flathub org.signal.Signal -y
# sudo flatpak override --env=SIGNAL_PASSWORD_STORE=gnome-libsecret org.signal.Signal