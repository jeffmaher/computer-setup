#!/bin/bash

# Check if the user is root (required for some bluetoothctl commands)
if [[ $EUID -ne 0 ]]; then
  echo "This script needs to be run with sudo."
  exit 1
fi

new_name="$1"

if [ -z "$new_name" ]; then
  echo "Usage: $0 <new_bluetooth_name>"
  exit 1
fi

echo "Setting Bluetooth name to: $new_name"

# Start bluetoothctl in interactive mode and send commands
bluetoothctl << EOF
  power on
  system-alias "$new_name"
  discoverable on
  exit
EOF

echo "Bluetooth name should now be set to '$new_name'."
echo "You might need to toggle Bluetooth off and on."

exit 0