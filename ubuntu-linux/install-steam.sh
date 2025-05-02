set -e

DOWNLOAD_LOCATION=/var/temp/steam.deb
wget https://cdn.cloudflare.steamstatic.com/client/installer/steam.deb -O $DOWNLOAD_LOCATION
sudo apt install ./steam.deb  -y
