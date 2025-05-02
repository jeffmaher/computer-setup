set -e

# From: https://mullvad.net/en/download/vpn/linux

# Fedora 41 and newer
# Add the Mullvad repository server to dnf
sudo dnf config-manager addrepo --overwrite --from-repofile=https://repository.mullvad.net/rpm/stable/mullvad.repo

# Install the package
sudo dnf install mullvad-vpn -y