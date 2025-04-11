set -e

# RUN INSTRUCTIONS
# - Add values for constants in this file
# - Run as sudo
# - Run in this directory
# - Comment out anything not wanted


# -- CONSTANTS --
UBUNTU_PRO_KEY=""
GIT_USER_NAME=""
GIT_USER_EMAIL=""
SSH_EMAIL=""


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

# -- PERFORM SETUP --
# Create a directory to work within
mkdir -p downloads
cd downloads

status "Update system packages"
apt update
apt upgrade -y
snap refresh

status "Turn on Firewall"
ufw enable
apt install gufw  -y

status "Attach to Ubuntu Pro"
pro attach $UBUNTU_PRO_KEY
pro disable livepatch

status "Install VIM as text editor"
apt install vim  -y
update-alternatives --set editor /usr/bin/vim.basic

status "Install DNS Over TLS and DNSSEC provider"
cat ../configs/dns_config.conf >> /etc/systemd/resolved.conf
systemctl restart systemd-resolved.service
systemctl restart NetworkManager.service

status "Install password manager"
wget https://downloads.1password.com/linux/debian/amd64/stable/1password-latest.deb
apt install ./1password-latest.deb  -y
post_setup "Setup password manager"

status "Install Firefox DEB package (instead of snap)"
snap remove --purge firefox
apt remove firefox
install -d -m 0755 /etc/apt/keyrings
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null
cat ../configs/firefox_repo.conf | tee /etc/apt/preferences.d/mozilla
apt update
apt install firefox  -y
post_setup "Setup Firefox"


status "Install Solaar for Logitech keyboards and mice"
add-apt-repository ppa:solaar-unifying/stable
apt update
apt install solaar  -y
post_setup "Disable Solaar from always running in the Startup App"
post_setup "Configure Solaar to use F keys"


status "Install Camera app"
apt install gnome-snapshot  -y


status "Install GNOME Extensions app and browser connector"
apt install gnome-browser-connector  -y


status "Install Slack"
post_setup "Setup Slack accounts"


status "Install Zoom video conferencing"
wget https://zoom.us/client/latest/zoom_amd64.deb
apt install ./zoom_amd64.deb  -y
post_setup "Login to Zoom"


status "Install Signal"
wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg
cat signal-desktop-keyring.gpg |  tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' | tee /etc/apt/sources.list.d/signal-xenial.list
apt update
apt install signal-desktop  -y
post_setup "Link Signal to phone"


status "Install Pinta for image/screenshot annotation"
snap install pinta


status "Install Kooha for screen recording"
snap install kooha


status "Install LosslessCut for simple video editing"
snap install losslesscut


status "Install Mullvad VPN"
curl -fsSLo /usr/share/keyrings/mullvad-keyring.asc https://repository.mullvad.net/deb/mullvad-keyring.asc
echo "deb [signed-by=/usr/share/keyrings/mullvad-keyring.asc arch=$( dpkg --print-architecture )] https://repository.mullvad.net/deb/stable $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/mullvad.list
apt update
apt install mullvad-vpn  -y
post_setup "Login to Mullvad VPN"


status "Install Git"
apt install git  -y
git config --global user.name "$GIT_USER_NAME"
git config --global user.email "$GIT_USER_EMAIL"


status "Setup SSH key"
ssh-keygen -t ed25519 -C "$SSH_EMAIL"
post_setup "Add SSH key to relevant places"


status "Install Google Cloud CLI"
apt-get install apt-transport-https ca-certificates gnupg curl -y
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg |  gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
apt update
apt install google-cloud-cli -y
post_setup "Login to Google Cloud CLI"


status "Install VLC media player"
snap install vlc
post_setup "Configure VLC UI"


status "Install Visual Studio Code"
snap install --classic code
post_setup "Setup Visual Studio Code"


status "Install Docker"
apt install ca-certificates curl  -y
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update
apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin  -y
apt install docker-desktop  -y
cat ../configs/docker_commands.sh >> ~/.bashrc
systemctl disable docker.service docker.socket
apt install pass  -y
post_setup "Generate a GPG key"
post_setup "Setup pass storage (to enable Docker login)"
post_setup "Login to Docker account"


status "Disable the screenshot sound"
mv /usr/share/sounds/freedesktop/stereo/camera-shutter.oga /usr/share/sounds/freedesktop/stereo/camera-shutter-disabled.oga


status "Install LibreOffice for opening MS Office docs and more complex PDF editing"
snap install libreoffice


status "Disable USB/XHCI wake from sleep"
cp ../configs/disable-usb-wakeup.service /etc/systemd/system/.
systemctl enable disable-usb-wakeup.service


status "Install Steam"
wget https://cdn.cloudflare.steamstatic.com/client/installer/steam.deb
apt install ./steam.deb  -y
post_setup "Login to Steam and configure Proton"


post_setup "Configure keyboard shortcuts (system and window tiling extension)"
post_setup "Configure settings in the Settings app"
post_setup "Configure Terminal app preferences"
post_setup "Get login screen to show up on the correct monitor"
post_setup "Install programming languages"

cd ..
echo "#### POST SETUP CHECKLIST ####"
echo $checklist
