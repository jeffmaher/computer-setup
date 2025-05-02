set -e

# Remove the default installed packages
sudo dnf remove firefox firefox-langpacks -y

# Install the official Mozilla Flatpak
flatpak install flathub org.mozilla.firefox -y