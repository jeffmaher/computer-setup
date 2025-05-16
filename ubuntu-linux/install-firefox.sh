set -e

# --- Debian Package ---
# Remove the Canonical packaged versions
snap remove --purge firefox
sudo apt remove firefox -y

# APT repo keys
sudo install -d -m 0755 /etc/apt/keyrings
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null

# Add APT repo
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null
cat configs/firefox_repo.conf | sudo tee /etc/apt/preferences.d/mozilla
sudo apt update
sudo apt install firefox  -y 

# --- Flatpack Package ---
# # Install the official Mozilla Flatpak
# flatpak install flathub org.mozilla.firefox -y