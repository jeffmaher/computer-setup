set -e

sudo cp configs/disable-usb-wakeup.service /etc/systemd/system/.
sudo systemctl enable disable-usb-wakeup.service