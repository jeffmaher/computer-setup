set -e


# --- Snap install ---
# Has problems retaining login for some workspaces, switch to Debian install (which isn't scriptable since they don't have a link to the latest version)
# sudo snap install slack

# --- Deb Install ---
# Gets an old release, but new ones can be gotten from https://slack.com/downloads/instructions/linux
# wget https://downloads.slack-edge.com/desktop-releases/linux/x64/4.45.69/slack-desktop-4.45.69-amd64.deb -O /var/tmp/slack.deb
# sudo apt install /var/tmp/slack.deb -y