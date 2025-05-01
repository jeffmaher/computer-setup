set -e

#####
Instructions:
1. Open terminal
1. Download this repo: git clone https://github.com/jeffmaher/computer-setup.git
1. Open setup.sh and fill in CHOICES/VARIABLES section
1. 

#####


# --- CHOICES / VARIABLES ---
# DNS choices: "cira" or "cloudflare"
export DNS_PROVIDER="cloudflare"


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
# Install updates
sudo dnf update --refresh -y

# Flatpak: For install applications (i.e. flatpaks)
sh install-flatpak.sh

# Setup DNS over TLS
# Reference: https://fedoramagazine.org/use-dns-over-tls/
sudo cp "configs/resolved-${DNS_PROVIDER}.conf" /etc/systemd/resolved.conf
sudo systemctl start systemd-resolved
sudo systemctl enable systemd-resolved
sudo systemctl restart NetworkManager
resolvectl status



# --- APPS ---

# Install VIM
sh install-vim.sh

# Uninstall Fedora's Firefox, and install Firefox from Flathub (officially maintained by Mozilla)
sudo dnf remove firefox firefox-langpacks -y
flatpak install flathub org.mozilla.firefox -y

# Install 1Password
# sudo needed since it's install a new repository
sudo flatpak install https://downloads.1password.com/linux/flatpak/1Password.flatpakref -y



# Zoom: Video conferencing app
sh install-zoom.sh


