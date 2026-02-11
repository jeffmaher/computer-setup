#!/bin/bash

# WiFi Drop Diagnostic Script for Framework Laptop
# Checks the last 24 hours for WiFi drops and possible causes

show_help() {
    cat << 'EOF'
WiFi Drop Diagnostic Script

Analyzes system logs to identify WiFi disconnections, roaming attempts,
and related issues. Designed for Framework Laptop with MediaTek MT7922.

USAGE:
    wifi-drops.sh [OPTIONS] [TIME_RANGE]

OPTIONS:
    -h, --help      Show this help message

TIME_RANGE:
    How far back to search. Defaults to "24 hours ago".
    Uses journalctl time format.

EXAMPLES:
    wifi-drops.sh                     # Last 24 hours
    wifi-drops.sh "1 hour ago"        # Last hour
    wifi-drops.sh "30 minutes ago"    # Last 30 minutes
    wifi-drops.sh "2025-02-10 14:00"  # Since specific time
    wifi-drops.sh today               # Since midnight

OUTPUT SECTIONS:
    DROP SUMMARY        Count of disconnects, roaming attempts, timeouts
    DROP TIMELINE       Chronological list of events
    ROAMING DETAILS     AP MAC addresses involved (different MAC = different band)
    ASSOC REJECTIONS    Router "comeback" messages (Roaming Assistant signature)
    KERNEL MESSAGES     Low-level driver events (requires sudo)
    CURRENT CONNECTION  Current band, signal strength, AP MAC
    POWER MANAGEMENT    WiFi power saving status

NOTES:
    - Run with sudo for complete kernel messages
    - Different AP MACs on same router usually indicate different bands
    - "comeback duration" messages suggest Roaming Assistant is active
EOF
    exit 0
}

# Parse arguments
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
fi

SINCE="${1:-24 hours ago}"

echo "=========================================="
echo "  WIFI DROP REPORT - $(date)"
echo "  Checking since: $SINCE"
echo "=========================================="
if [ "$EUID" -ne 0 ]; then
    echo "  ⚠ Not running as root - kernel messages will be limited"
    echo "  Tip: Run with sudo for full diagnostics"
    echo "=========================================="
fi
echo

# --- Summary of drops ---
echo "=== DROP SUMMARY ==="
echo
DISCONNECTS=$(journalctl --since "$SINCE" | grep -c "supplicant interface state: completed -> authenticating\|supplicant interface state: completed -> disconnected")
ROAM_ATTEMPTS=$(journalctl --since "$SINCE" | grep -c "disconnect from AP.*for new auth to")
ASSOC_REJECTS=$(journalctl --since "$SINCE" | grep -c "rejected association temporarily")
ASSOC_TIMEOUTS=$(journalctl --since "$SINCE" | grep -c "association with.*timed out")

echo "  Disconnects from completed state: $DISCONNECTS"
echo "  Roaming attempts (band switches): $ROAM_ATTEMPTS"
echo "  Association rejections (comeback): $ASSOC_REJECTS"
echo "  Association timeouts: $ASSOC_TIMEOUTS"
echo

# --- Timeline of drops ---
echo "=== DROP TIMELINE ==="
echo
journalctl --since "$SINCE" | grep -E "completed -> authenticating|completed -> disconnected|disconnect from AP.*for new auth|rejected association|association with.*timed out|: authenticated$|: associated$" | while read line; do
    timestamp=$(echo "$line" | awk '{print $1, $2, $3}')
    
    if echo "$line" | grep -q "completed -> authenticating"; then
        echo "$timestamp - DROP: Spontaneous re-authentication triggered"
    elif echo "$line" | grep -q "completed -> disconnected"; then
        echo "$timestamp - DROP: Disconnected from completed state"
    elif echo "$line" | grep -q "disconnect from AP.*for new auth"; then
        old_ap=$(echo "$line" | grep -oP "disconnect from AP \K[a-f0-9:]+")
        new_ap=$(echo "$line" | grep -oP "for new auth to \K[a-f0-9:]+")
        echo "$timestamp - ROAM: Switching from $old_ap to $new_ap"
    elif echo "$line" | grep -q "rejected association temporarily"; then
        duration=$(echo "$line" | grep -oP "comeback duration \K[0-9]+")
        echo "$timestamp - REJECT: Router said wait ${duration} TU (~$((duration)) ms)"
    elif echo "$line" | grep -q "association with.*timed out"; then
        echo "$timestamp - TIMEOUT: Association attempt failed"
    elif echo "$line" | grep -q ": authenticated$"; then
        echo "$timestamp - OK: Authenticated"
    elif echo "$line" | grep -q ": associated$"; then
        echo "$timestamp - OK: Associated (reconnected)"
    fi
done
echo

# --- Roaming details ---
if [ "$ROAM_ATTEMPTS" -gt 0 ]; then
    echo "=== ROAMING DETAILS ==="
    echo
    echo "APs involved in roaming (MAC addresses):"
    journalctl --since "$SINCE" | grep -oP "(disconnect from AP |for new auth to |authenticate with )\K[a-f0-9:]+" | sort | uniq -c | sort -rn | head -10
    echo
    echo "Note: Different MACs on same router = different bands (5GHz vs 6GHz)"
    echo
fi

# --- Association rejections (Roaming Assistant signature) ---
if [ "$ASSOC_REJECTS" -gt 0 ]; then
    echo "=== ASSOCIATION REJECTIONS ==="
    echo
    echo "These 'comeback duration' messages indicate the router told your"
    echo "laptop to wait before reconnecting (often caused by Roaming Assistant):"
    echo
    journalctl --since "$SINCE" | grep "rejected association temporarily" | tail -10
    echo
fi

# --- Kernel WiFi messages ---
echo "=== KERNEL WIFI MESSAGES (last 20) ==="
echo
sudo dmesg 2>/dev/null | grep -i "wlp1s0\|mt79" | grep -v "UFW BLOCK" | tail -20
if [ $? -ne 0 ]; then
    echo "(Run with sudo to see kernel messages)"
fi
echo

# --- Current connection info ---
echo "=== CURRENT CONNECTION ==="
echo
IFACE="wlp1s0"
if ip link show "$IFACE" &>/dev/null; then
    SSID=$(iwgetid -r 2>/dev/null || echo "Not connected")
    FREQ=$(iwgetid -f 2>/dev/null | grep -oP "Frequency:\K[0-9.]+" || echo "Unknown")
    SIGNAL=$(iwconfig "$IFACE" 2>/dev/null | grep -oP "Signal level=\K-?[0-9]+")
    
    echo "  Interface: $IFACE"
    echo "  SSID: $SSID"
    echo "  Frequency: $FREQ GHz"
    echo "  Signal: $SIGNAL dBm"
    
    # Determine band from frequency
    if [ -n "$FREQ" ]; then
        FREQ_INT=$(echo "$FREQ" | cut -d. -f1)
        if [ "$FREQ_INT" -ge 5900 ]; then
            echo "  Band: 6 GHz"
        elif [ "$FREQ_INT" -ge 5100 ]; then
            echo "  Band: 5 GHz"
        elif [ "$FREQ_INT" -ge 2400 ]; then
            echo "  Band: 2.4 GHz"
        fi
    fi
    
    # Get current AP MAC
    AP_MAC=$(iwgetid -a 2>/dev/null | grep -oP "Access Point: \K[A-F0-9:]+")
    echo "  AP MAC: $AP_MAC"
fi
echo

# --- Power management status ---
echo "=== WIFI POWER MANAGEMENT ==="
echo
iwconfig "$IFACE" 2>/dev/null | grep -i "power management"
if [ -f /etc/NetworkManager/conf.d/wifi-powersave-off.conf ]; then
    echo "  (wifi-powersave-off.conf exists)"
else
    echo "  (No custom power save config found)"
fi
echo

echo "=========================================="
echo "  END OF REPORT"
echo "=========================================="
echo
echo "Tip: Run with a time range: $0 \"1 hour ago\""
