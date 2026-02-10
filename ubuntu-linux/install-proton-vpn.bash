set -e

# Instructions from https://protonvpn.com/support/official-linux-vpn-ubuntu/

DOWNLOAD_LOCATION=/var/tmp/protonvpn-stable-release_1.0.8_all.deb
wget https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.8_all.deb -O $DOWNLOAD_LOCATION
sudo dpkg -i ./protonvpn-stable-release_1.0.8_all.deb && sudo apt update
sudo apt install proton-vpn-gnome-desktop
sudo apt install gnome-shell-extension-appindicator


# Removal instructions
# sudo apt autoremove proton-vpn-gnome-desktop && sudo apt purge protonvpn-stable-release