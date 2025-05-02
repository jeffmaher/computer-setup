set -e

# Install pass to enable Docker logins
sudo apt install pass  -y

# Setup package repository
sudo apt install ca-certificates curl  -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
sudo echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update

# Install Docker Desktop
DOWNLOAD_LOCATION=/var/tmp/docker-desktop-amd64.deb
wget "https://desktop.docker.com/linux/main/amd64/docker-desktop-amd64.deb" -O $DOWNLOAD_LOCATION
sudo apt install $DOWNLOAD_LOCATION -y