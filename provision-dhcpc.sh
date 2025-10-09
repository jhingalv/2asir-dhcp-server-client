#!/bin/bash

# Show the console lines to see posible errors
set -exu

apt-get update
apt-get upgrade -y

# Dhclient should be already installed, but we will ensure it
apt-get install -y isc-dhcp-client

# Get interface name connected to internal network
IFACE=$(ip -o link show | awk -F': ' '{print $2}' | grep -v lo | head -n1)

# Configure netplan to use DHCP on the interface
cat <<EOF > /etc/netplan/01-netcfg.yaml
network:
  version: 2
  ethernets:
    $IFACE:
      dhcp4: true
EOF

# Apply the config
netplan apply

# Restart the interface to ensure that it takes DHCP
ip link set "$IFACE" down
ip link set "$IFACE" up

# Force DHCP request (just in case)
dhclient -v "$IFACE"

# Check network config to verify the asigned IP
ip a