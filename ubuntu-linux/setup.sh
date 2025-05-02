set -e

# Run after setup-system.sh and rebooting
# Tested on Ubuntu Linux 24.04
# USAGE: sh setup.sh 

# -- OUTPUT FUNCTIONS --
current_step=0
status() {
    echo "##### [$current_step]: $1 #####"
    current_step=current_step+1
}

checklist=""
post_setup() {
    checklist="$checklist\n- $1"
}

# -- INSTALL APPS --
status "Install VIM as text editor"
sh install-vim.sh

status "Install Solaar for managing Logitech keyboards and mice"
sh install-solaar.sh
checklist "Solaar: Setup keyboard and mouse bindings"
checklist "Solaar: Verify that it isn't starting up at startup"

status "Install GNOME Extensions app"
sh install-gnome-extensions-app.sh

status "Install Mozilla Firefox"
sh install-firefox.sh
checklist "Mozilla Firefox: Setup profiles"
checklist "Mozilla Firefox: Configure password manager"
checklist "Mozilla Firefox: Configure privacy settings"

status "Install Google Chrome"
sh install-google-chrome.sh
checklist "Google Chrome: Setup profiles"
checklist "Google Chrome: Configure password manager"
checklist "Google Chrome: Configure privacy settings"
checklist "Google Chrome: Setup PWAs"

status "Install 1Password"
sh install-1password.sh

status "Install Visual Studio Code"
sh install-vscode.sh

status "Install Solaar for Logitech keyboards and mice"
sh install-solaar.sh
post_setup "Disable Solaar from always running in the Startup App"
post_setup "Configure Solaar to use F keys"

status "Install Camera for testing webcam"
sh install-cameria.sh

status "Install Signal Private Messenger"
sh install-signal.sh
checklist "Signal: Sync with phone"

status "Install Pinta for light image editings and screenshot markup"
sh install-pinta.sh

# TODO Choose between Kooha or VokoscreenNG
status "Install Kooha for screen and audio capture"
sh install-kooha.sh
# status "Install VokoscreenNG for screen recording"
# sudo apt install vokoscreen-ng

status "Install Lossless Cut for video trimming"
sh install-lossless-cut.sh

status "Install Mullvad for VPNing"
sh install-mullvad.sh
checklist "Mullvad: Login to VPN account"

status "Install Zoom Video Conferencing"
sh install-zoom.sh
checklist "Zoom: Login"

status "Install Google Cloud CLI"
sh install-gcp-cli.sh
post_setup "GCP: Login"

status "Install GNOME Videos/Totem"
sh install-video-player.sh

status "Install Docker"
sh install-docker-desktop.sh
post_setup "Docker: Generate a GPG key"
post_setup "Docker: Setup pass storage (to enable Docker login)"
post_setup "Docker: Login"

status "Install LibreOffice for opening MS Office docs and more complex PDF editing"
sh install-libre-office.sh


# status "Install Steam"
# sh install-steam.sh
# post_setup "Login to Steam and configure Proton"


post_setup "Configure keyboard shortcuts (system and window tiling extension)"
post_setup "Configure settings in the Settings app"
post_setup "Configure Terminal app preferences"
post_setup "Get login screen to show up on the correct monitor"
post_setup "Install programming languages"
post_setup "Evaluate X11 vs. Wayland depending on the system"

cd ..
echo "#### POST SETUP CHECKLIST ####"
echo $checklist
