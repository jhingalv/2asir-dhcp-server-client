#!/bin/bash

# Show the console lines to see posible errors
set -exu

apt-get update
apt-get upgrade -y

# Install the DHCP service
apt-get install -y isc-dhcp-server

# Search the DHCP interface
IFACE=$(ip -o -4 addr show | grep 192.168.57.10 | awk '{print $2}')

# Make DHCP use that interface
sed -i "s/^INTERFACESv4=.*/INTERFACESv4=\"$IFACE\"/" /etc/default/isc-dhcp-server

# Restart the DHCP service
systemctl restart isc-dhcp-server

# Make a backup of the DHCP config file
cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.bak

# Add the DHCP config to the file
cat > /etc/dhcp/dhcpd.conf <<EOF
default-lease-time 86400;   # 1 día (en segundos)
max-lease-time 691200;      # 8 días (en segundos)
authoritative;              # Pues es el único sv

subnet 192.168.57.0 netmask 255.255.255.0 {
  range 192.168.57.25 192.168.57.50;
  option routers 192.168.57.10;
  option subnet-mask 255.255.255.0;
  option broadcast-address 192.168.57.255;
  option domain-name-servers 8.8.8.8, 4.4.4.4;
  option domain-name "micasa.es";
}
EOF

# Restart and enable the DHCP service to apply changes
systemctl restart isc-dhcp-server.service
systemctl enable isc-dhcp-server.service

# Check that the service is running properly
systemctl status isc-dhcp-server.service --no-pager # --no-pager avoids interruptions

# Check that the socket is listening
ss -lun