set -e

flatpak install flathub com.google.Chrome -y


mkdir -p ~/.local/share/applications
mkdir -p ~/.local/share/icons
flatpak override --user --filesystem=~/.local/share/icons --filesystem=~/.local/share/applications com.google.Chrome