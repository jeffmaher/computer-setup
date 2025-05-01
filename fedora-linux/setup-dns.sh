set -e
# Reference: https://fedoramagazine.org/use-dns-over-tls/

sudo cp "configs/resolved.conf" /etc/systemd/.
sudo cp "configs/10-dns-systemd-resolved.conf" /etc/NetworkManager/conf.d/.


sudo systemctl stop systemd-resolved
sudo systemctl enable systemd-resolved
sudo systemctl start systemd-resolved
sudo systemctl restart NetworkManager


resolvectl status