set -e

DOWNLOAD_LOCATION=/var/tmp/steam.deb
wget https://cdn.cloudflare.steamstatic.com/client/installer/steam.deb -O $DOWNLOAD_LOCATION
sudo apt install $DOWNLOAD_LOCATION  -y

# Open ports for local network download sharing
sudo ufw allow 27040/tcp
sudo ufw allow 27031:27036/udp