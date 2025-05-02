# USAGE: sh config-git.sh <global user.name> <global user.email>
set -e

git config --global user.name $1
git config --global user.email $2