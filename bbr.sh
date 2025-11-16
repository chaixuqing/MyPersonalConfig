#!/bin/bash

# Check and enable BBR congestion control for better network performance
# 1. Display current kernel version
echo "Current Linux kernel version: $(uname -r)"

# 2. Check if BBR and FQ are available in kernel
echo "Checking BBR and FQ availability in kernel configuration..."
grep -E 'CONFIG_TCP_CONG_BBR|CONFIG_NET_SCH_FQ' "/boot/config-$(uname -r)"

# 3. Show current congestion control settings
echo "Current TCP congestion control settings:"
sysctl -n net.ipv4.tcp_available_congestion_control
sysctl -n net.ipv4.tcp_congestion_control

# 4. Enable BBR and FQ queuing discipline
echo "Enabling BBR and FQ..."
sudo sysctl -w net.ipv4.tcp_congestion_control=bbr # Enable BBR algorithm
sudo sysctl -w net.core.default_qdisc=fq          # Enable Fair Queuing

# Use fq so kernel pacing works accurately (required for BBR)
sudo sysctl -w net.core.default_qdisc = fq

# Enable TCP BBR (v1)
sudo sysctl -w net.ipv4.tcp_congestion_control = bbr

# Enable ECN with fallback (helps coexistence/AQM; safe if middleboxes strip ECN)
sudo sysctl -w net.ipv4.tcp_ecn = 1
# Keep fallback enabled (default) so ECN auto-disables if the path is hostile
# net.ipv4.tcp_ecn_fallback = 1

# Optional: modest buffer ceilings to avoid excessive queueing while keeping high-BDP stability
sudo sysctl -w net.ipv4.tcp_rmem = 4096 131072 6291456
sudo sysctl -w net.ipv4.tcp_wmem = 4096 131072 6291456

# 5. Apply changes and verify
echo "Applying changes..."
sudo sysctl -p                                     # Load changes

echo "Verifying new settings:"
sysctl -n net.ipv4.tcp_congestion_control         # Should show 'bbr'
sysctl -n net.core.default_qdisc                  # Should show 'fq'
