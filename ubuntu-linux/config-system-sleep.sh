set -e

cp ../configs/disable-usb-wakeup.service /etc/systemd/system/.
systemctl enable disable-usb-wakeup.service