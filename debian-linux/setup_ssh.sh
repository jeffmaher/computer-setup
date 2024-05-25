#!/usr/bin/bash
set -e

# Install SSH
sudo apt install openssh-client -y

# Setup an SSH key
ssh-keygen -t ed25519

# Add SSH init to .bashrc
cat bashrc_ssh.txt >> ~/.bashrc

# Whenever you want to add your SSH key, run `ssh-add` (which will prompt you for your password)
