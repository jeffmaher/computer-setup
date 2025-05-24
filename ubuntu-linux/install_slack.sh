set -e


# --- Snap install ---
# Has problems retaining login for some workspaces, switch to Debian install (which isn't scriptable since they don't have a link to the latest version)
sudo snap install slack