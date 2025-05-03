
cat ../configs/dns_config.conf >> /etc/systemd/resolved.conf
sudo systemctl restart systemd-resolved.service
sudo systemctl restart NetworkManager.service