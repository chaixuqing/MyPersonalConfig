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

# 5. Apply changes and verify
echo "Applying changes..."
sudo sysctl -p                                     # Load changes

echo "Verifying new settings:"
sysctl -n net.ipv4.tcp_congestion_control         # Should show 'bbr'
sysctl -n net.core.default_qdisc                  # Should show 'fq'
