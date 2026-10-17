#!/bin/zsh

# Update UV
#
# - uv is installed per user, so this updates the current account's copy.

echo "uv ($(whoami)):"

if command -v uv >/dev/null 2>&1; then
    uv self update
else
    echo "  - uv not installed in this account (skipped)"
fi
