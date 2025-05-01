set -e

#####
# Instructions:
# 1. Open terminal
# 1. Download this repo: git clone https://github.com/jeffmaher/computer-setup.git
# 1. Open setup.sh and fill in CHOICES/VARIABLES section
# 1. 
#
#####


# --- CHOICES / VARIABLES ---
# DNS choices: "cira" or "cloudflare"
# export DNS_PROVIDER="cloudflare"


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

# --- SYSTEM ITEMS ---
status "Update system packages"
sudo dnf update --refresh -y

status "Install Flatpak"
sh install-flatpak.sh

status "Setup DNS over TLS and DNSSEC"
sh setup-dns.sh

# --- APPS ---

status "Install GNOME Tweaks for controlling startup apps"
# TODO

status "Install VIM"
sh install-vim.sh

status "Install Mozilla Firefox"
sh install-firefox.sh

status "Install 1Password"
sh install-1password.sh

status "Install Solaar for managing Logitech devices"
# sh install-solaar.sh
# TODO

status "Install Visual Studio Code"
flatpak install flathub com.visualstudio.code -y
#flatpak install flathub com.vscodium.codium -y


status "Install Google Chrome"
sh install-google-chrome.sh


status "Install Slack chat tool"
# TODO

# TODO GNOME Extensions app
# TODO Signal
# TODO Pinta
# TODO Kooha or VokoscreenNG
# TODO LosslessCut
# TODO Mullvad VPN
# TODO Git
# TODO SSH
# TODO VLC or Totem
# TODO Docker
# TODO Disable screenshot sound
# TODO Steam
# TODO Disable USB Wakeup


status "Install Zoom Video Conferencing"
sh install-zoom.sh