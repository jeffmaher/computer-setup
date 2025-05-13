set -e

DOWNLOAD_LOCATION=/var/tmp/google-chrome-stable_current_amd64.deb

# Official installation for Debian package
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O $DOWNLOAD_LOCATION
sudo apt install $DOWNLOAD_LOCATION -y

# Flatpak FlatHub install
# flatpak install flathub com.google.Chrome -y
# mkdir -p ~/.local/share/applications
# mkdir -p ~/.local/share/icons
# flatpak override --user --filesystem=~/.local/share/icons --filesystem=~/.local/share/applications com.google.Chrome