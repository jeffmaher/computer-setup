set -e

sudo tee /etc/udev/rules.d/81-disable-wol.rules << 'EOF'
ACTION=="add", SUBSYSTEM=="net", NAME=="en*", RUN+="/usr/sbin/ethtool -s $name wol d"
EOF

sudo udevadm control --reload-rules

# -- To Check, run --
# ip link | grep enx
# sudo ethtool <interface_name> | grep Wake-on

# -- To undo, run --
# sudo rm /etc/udev/rules.d/81-disable-wol.rules
# sudo udevadm control --reload-rules
