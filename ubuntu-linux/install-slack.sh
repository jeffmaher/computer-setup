#!/usr/bin/env bash
set -euo pipefail

sudo install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://packagecloud.io/slacktechnologies/slack/gpgkey \
  | gpg --dearmor \
  | sudo tee /etc/apt/keyrings/slacktechnologies_slack-archive-keyring.gpg > /dev/null

sudo tee /etc/apt/sources.list.d/slack.sources > /dev/null <<'EOF'
Types: deb
URIs: https://packagecloud.io/slacktechnologies/slack/debian/
Suites: jessie
Components: main
Architectures: amd64
Signed-By: /etc/apt/keyrings/slacktechnologies_slack-archive-keyring.gpg
EOF

sudo apt update
sudo apt install -y slack-desktop

