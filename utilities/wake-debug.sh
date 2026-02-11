#!/bin/bash

# Wake Debug Script for Framework Laptop
# Helps diagnose what's causing wake events and when they occur

echo "=========================================="
echo "  WAKE DEBUG REPORT - $(date)"
echo "=========================================="
echo

# --- Recent suspend/resume events ---
echo "=== RECENT SUSPEND/RESUME EVENTS (last 24 hours) ==="
echo
journalctl --since "24 hours ago" | grep -E "suspend entry|suspend exit" | tail -30
echo

# --- Last wake source ---
echo "=== LAST WAKE SOURCE ==="
echo
WAKE_IRQ=$(cat /sys/power/pm_wakeup_irq 2>/dev/null)
if [ -n "$WAKE_IRQ" ]; then
    echo "Wake IRQ: $WAKE_IRQ"
    # Try to identify what device uses this IRQ
    grep "^ *$WAKE_IRQ:" /proc/interrupts | head -1
else
    echo "No wake IRQ recorded"
fi
echo

# --- Wake-enabled devices ---
echo "=== WAKE-ENABLED DEVICES ==="
echo
for dev in /sys/bus/*/devices/*/power/wakeup; do
    if [ -f "$dev" ] && [ "$(cat "$dev" 2>/dev/null)" = "enabled" ]; then
        devpath=$(dirname $(dirname "$dev"))
        devname=$(basename "$devpath")
        # Try to get a friendly name
        if [ -f "$devpath/product" ]; then
            product=$(cat "$devpath/product" 2>/dev/null)
            echo "  $devname: $product"
        elif [ -f "$devpath/description" ]; then
            desc=$(cat "$devpath/description" 2>/dev/null)
            echo "  $devname: $desc"
        else
            echo "  $devname"
        fi
    fi
done 2>/dev/null
echo

# --- Ethernet Wake-on-LAN settings ---
echo "=== ETHERNET WAKE-ON-LAN SETTINGS ==="
echo
for iface in $(ip -o link show | awk -F': ' '{print $2}' | grep -v "^lo$"); do
    wol=$(ethtool "$iface" 2>/dev/null | grep "Wake-on:" | awk '{print $2}')
    if [ -n "$wol" ]; then
        echo "  $iface: Wake-on: $wol"
        if [ "$wol" != "d" ]; then
            echo "    ^ WARNING: Wake-on-LAN is enabled (d = disabled)"
        fi
    fi
done
echo

# --- USB devices that can wake ---
echo "=== USB DEVICES WITH WAKE ENABLED ==="
echo
for dev in /sys/bus/usb/devices/*/power/wakeup; do
    if [ -f "$dev" ] && [ "$(cat "$dev" 2>/dev/null)" = "enabled" ]; then
        devpath=$(dirname $(dirname "$dev"))
        if [ -f "$devpath/product" ]; then
            product=$(cat "$devpath/product" 2>/dev/null)
            manufacturer=$(cat "$devpath/manufacturer" 2>/dev/null)
            echo "  $(basename $devpath): $manufacturer $product"
        fi
    fi
done 2>/dev/null
echo

# --- ACPI wakeup sources ---
echo "=== ACPI WAKEUP SOURCES (enabled) ==="
echo
cat /proc/acpi/wakeup 2>/dev/null | grep -E "\*enabled" | while read line; do
    echo "  $line"
done
echo

# --- GPE events (can indicate wake sources) ---
echo "=== ACPI GPE EVENTS (non-zero) ==="
echo
grep -v "^\s*0$" /sys/firmware/acpi/interrupts/gpe* 2>/dev/null | grep -v ":0$" | head -10
echo

# --- Recent kernel messages around wake ---
echo "=== KERNEL MESSAGES FROM LAST WAKE ==="
echo
# Find the last resume and show messages around it
journalctl -b -k | grep -A5 "PM: suspend exit" | tail -20
echo

# --- Systemd timers that might wake ---
echo "=== ACTIVE SYSTEMD TIMERS ==="
echo
systemctl list-timers --no-pager | head -15
echo

echo "=========================================="
echo "  END OF REPORT"
echo "=========================================="
