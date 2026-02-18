set -e

DOWNLOAD_PATH=/var/tmp/ente.deb

# https://github.com/ente-io/photos-desktop/releases/download/v1.7.18/ente-1.7.18-amd64.deb
wget "https://github.com/ente-io/photos-desktop/releases/download/v1.7.18/ente-1.7.18-amd64.deb" -O $DOWNLOAD_PATH

sudo apt install /var/tmp/ente.deb $DOWNLOAD_PATH -y