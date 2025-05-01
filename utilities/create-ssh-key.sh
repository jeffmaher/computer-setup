# USAGE: sh create-ssh-key.sh <email>

set -e

ssh-keygen -t ed25519 -C $1