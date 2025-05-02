set -e
# Reference: https://fedoramagazine.org/use-dns-over-tls/

sudo cp "configs/resolved-$1.conf" /etc/systemd/resolved.conf
sudo cp "configs/10-dns-systemd-resolved.conf" /etc/NetworkManager/conf.d/.


sudo systemctl stop systemd-resolved
sudo systemctl enable systemd-resolved
sudo systemctl start systemd-resolved
sudo systemctl restart NetworkManager


resolvectl status