set -e

flatpak install flathub org.signal.Signal -y
sudo flatpak override --env=SIGNAL_PASSWORD_STORE=gnome-libsecret org.signal.Signal