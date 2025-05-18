set -e

# USAGE: sh setup-system.sh
# Tested on Ubuntu Desktop 24.04.2 LTS and 25.04 


# --- FUNCTIONS ---
status() {
    echo "##### $1 #####"
}

status "Check permissions"
sudo --validate


# --- SYSTEM AND FOUNDATIONAL ITEMS ---
status "Turn on Firewall"
sudo ufw enable
sudo apt install gufw  -y

# status "Attach to Ubuntu Pro"
# sudo pro attach $1
# sudo pro disable livepatch

status "Update system packages"
sudo apt update
sudo apt upgrade -y
snap refresh

status "Install DNS Over TLS and DNSSEC provider"
sh config-dns.sh

status "Install Flatpak"
sh install-flatpak.sh

status "Configure screenshots"
sh config-screenshots.sh

status "Install Git"
sh install-git.sh

status "Disable USB/XHCI wake from sleep"
sh config-system-sleep.sh

status "Rebooting"
sudo systemctl reboot -i
