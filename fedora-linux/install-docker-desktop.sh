set -e

# Add Docker's DNF repository
sudo dnf config-manager addrepo --overwrite --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo

# Download the latest RPM
DOWNLOAD_LOCATION=/var/tmp/docker-desktop-x86_64.rpm
wget "https://desktop.docker.com/linux/main/amd64/docker-desktop-x86_64.rpm" -O $DOWNLOAD_LOCATION

# Install
sudo dnf install $DOWNLOAD_LOCATION -y