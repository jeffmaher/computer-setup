set -e

# Update packages, including Docker Engine related ones
sudo apt update && sudo apt upgrade -y

# Install Docker Desktop
DOWNLOAD_LOCATION=/var/tmp/docker-desktop-amd64.deb
wget "https://desktop.docker.com/linux/main/amd64/docker-desktop-amd64.deb" -O $DOWNLOAD_LOCATION
sudo apt install $DOWNLOAD_LOCATION -y