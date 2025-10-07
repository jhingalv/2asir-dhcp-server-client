#!/bin/bash

# Show the console lines to see posible errors
set -exu

apt-get update
apt-get upgrade -y

# Dhclient should be already installed, but we will ensure it
apt-get install -y isc-dhcp-client

# Configure netplan to use DHCP on the interface
cat <<EOF > /etc/netplan/01-netcfg.yaml
network:
  version: 2
  ethernets:
    enp0s3:
      dhcp4: true
EOF

# Apply the config
netplan apply

# Restart the interface to ensure that it takes DHCP
ip link set enp0s3 down
ip link set enp0s3 up

# Force the DHCP request (just in case)
dhclient -v enp0s3

# Check network config to verify the asigned IP
ip a