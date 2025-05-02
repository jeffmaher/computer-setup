
cat ../configs/dns_config.conf >> /etc/systemd/resolved.conf
systemctl restart systemd-resolved.service
systemctl restart NetworkManager.service