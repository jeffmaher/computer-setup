set -e

#####
# Tested on Fedora Workstation 42
# Instructions:
# 1. Open terminal
# 1. Download this repo: git clone https://github.com/jeffmaher/computer-setup.git
# 1. Open this file and fill in CHOICES/VARIABLES section
#
#####


# --- CHOICES / VARIABLES ---
# DNS choices: "cira" or "cloudflare"
DNS_PROVIDER="cloudflare"
SYSTEM_NAME="linux"
GIT_USER_NAME=""
GIT_USER_EMAIL=""



# --- FUNCTIONS ---
status() {
    echo "##### $1 #####"
}

# --- SYSTEM AND FOUNDATIONAL ITEMS ---
status "Update system packages"
sudo dnf update --refresh -y

status "Setup DNS over TLS and DNSSEC"
sh config-dns.sh $DNS_PROVIDER

status "Configure how the system identifies itself"
sudo sh config-bluetooth.sh $SYSTEM_NAME
sudo hostnamectl set-hostname $SYSTEM_NAME

status "Install Solaar for managing Logitech keyboards and mice"
sh install-solaar.sh

status "Install GNOME Extensions app"
sh install-gnome-extensions-app.sh
gnome-extensions disable background-logo@fedorahosted.org

status "Install GNOME Tweaks for controlling startup apps"
sh install-gnome-tweaks.sh

status "Configure Git"
sh config-git.sh $GIT_USER_EMAIL $GIT_USER_EMAIL

status "Configure screenshots"
sh config-screenshots.sh

# --- APPS ---
status "Remove default apps"
sh uninstall-default-apps.sh


status "Install VIM"
sh install-vim.sh

status "Install Mozilla Firefox"
sh install-firefox.sh

status "Install 1Password"
sh install-1password.sh

status "Install Visual Studio Code"
#flatpak install flathub com.visualstudio.code -y
flatpak install flathub com.vscodium.codium -y


status "Install Google Chrome"
sh install-google-chrome.sh

# status "Install Slack chat tool"
# sh install-slack.sh

status "Install Signal Private Messenger"
sh install-signal.sh

status "Install Pinta for light image editings and screenshot markup"
sh install-pinta.sh

# TODO Choose between Kooha or VokoscreenNG
status "Install Kooha for screen and audio capture"
sh install-kooha.sh

status "Install Lossless Cut for video trimming"
sh install-lossless-cut.sh

status "Install Mullvad for VPNing"
sh install-mullvad.sh


status "Install Docker for OS/runtime containers"
sh install-docker-desktop.sh

# TODO VLC if GNOME Videos (i.e. Totem) isn't working well
# TODO Disable USB Wakeup
