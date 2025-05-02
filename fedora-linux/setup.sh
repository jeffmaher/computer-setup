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
current_step=0
status() {
    echo "##### [$current_step]: $1 #####"
    declare -g current_step=$((current_step + 1))
}

checklist=""
post_setup() {
    declare -g checklist="$checklist\n- $1"
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
checklist "Solaar: Setup keyboard and mouse bindings"
checklist "Solaar: Verify that it isn't starting up at startup"

status "Install GNOME Extensions app"
sh install-gnome-extensions-app.sh
gnome-extensions disable background-logo@fedorahosted.org

status "Install GNOME Tweaks for controlling startup apps"
sh install-gnome-tweaks.sh

status "Configure Git"
sh config-git.sh $GIT_USER_EMAIL $GIT_USER_EMAIL
checklist "Git: Create SSH key and upload public key to services"

status "Configure screenshots"
sh config-screenshots.sh
checklist "Screenshots: Enable showing the pointer"


# --- APPS ---
status "Remove default apps"
sh uninstall-default-apps.sh


status "Install VIM"
sh install-vim.sh

status "Install Mozilla Firefox"
sh install-firefox.sh
checklist "Mozilla Firefox: Setup profiles"
checklist "Mozilla Firefox: Configure password manager"
checklist "Mozilla Firefox: Configure privacy settings"

status "Install 1Password"
sh install-1password.sh

status "Install Visual Studio Code"
flatpak install flathub com.visualstudio.code -y
#flatpak install flathub com.vscodium.codium -y
checklist "Visual Studio Code: Import or sync settings"

status "Install Google Chrome"
sh install-google-chrome.sh
checklist "Google Chrome: Setup profiles"
checklist "Google Chrome: Configure password manager"
checklist "Google Chrome: Configure privacy settings"
checklist "Google Chrome: Setup PWAs"

# Switched to browser PWA
# status "Install Slack chat tool"
# sh install-slack.sh

status "Install Signal Private Messenger"
sh install-signal.sh
checklist "Signal: Sync with phone"

status "Install Pinta for light image editings and screenshot markup"
sh install-pinta.sh

# TODO Choose between Kooha or VokoscreenNG
status "Install Kooha for screen and audio capture"
sh install-kooha.sh

status "Install Lossless Cut for video trimming"
sh install-lossless-cut.sh

status "Install Mullvad for VPNing"
sh install-mullvad.sh
checklist "Mullvad: Login to VPN account"




status "Install Docker for OS/runtime containers"
sh install-docker-desktop.sh
checklist "Docker Desktop: Confirm that Docker runtime isn't always running"
checklist "Docker Desktop: Initialize pass. See https://docs.docker.com/desktop/setup/sign-in/#signing-in-with-docker-desktop-for-linux"
checklist "Docker Desktop: Login"


# TODO VLC if GNOME Videos (i.e. Totem) isn't working well
# TODO Steam
# TODO Disable USB Wakeup


