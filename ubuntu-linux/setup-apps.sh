set -e

# Installs applications for day-to-day use
# Run after setup-system.sh and rebooting
# Tested on Ubuntu Linux 24.04 and 25.10
# USAGE: sh setup-apps.sh 

# -- OUTPUT FUNCTIONS --
status() {
    echo "\n\n##### $1 #####"
}

status "Check permissions"
sudo --validate

# -- INSTALL APPS --
status "Install VIM as text editor"
sh install-vim.sh

status "Install Solaar for managing Logitech keyboards and mice"
sh install-solaar.sh

status "Install GNOME Extensions app"
sh install-gnome-extensions-app.sh

status "Install Mozilla Firefox"
sh install-firefox.sh

status "Install Google Chrome"
sh install-google-chrome.sh

status "Install 1Password"
sh install-1password.sh

status "Install Sublime Text and Merge"
sh install-sublime.sh

status "Install Camera for testing webcam"
sh install-camera.sh

status "Install Camera Control for changing webcam settings"
sh install-cameractrl.sh

status "Install Signal Private Messenger"
sh install-signal.sh

status "Install Pinta for light image editing and screenshot markup"
sh install-pinta.sh

# status "Install Screen Capture software"
# sh install-screen-capture.sh

status "Install Lossless Cut for video trimming"
sh install-lossless-cut.sh

status "Install VLC Video Player"
sh install-video-player.sh

status "Install Docker"
sh install-docker-desktop.sh

status "Install LibreOffice for opening MS Office docs and more complex PDF editing"
sh install-libre-office.sh

status "Install Todoist"
sh install-todoist.sh

status "Done installing apps!"
