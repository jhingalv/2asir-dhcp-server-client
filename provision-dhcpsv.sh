#!/bin/bash

# Mostramos lineas para ver errores
set -exu

apt-get update
apt-get upgrade -y

# Instalamos el servicio DHCP
apt-get install -y isc-dhcp-server

# Buscamos la interfaz que usará el DHCP
IFACE=$(ip -o -4 addr show | grep 192.168.57.10 | awk '{print $2}')

# Hacemos que el servicio use la interfaz anterior
sed -i "s/^INTERFACESv4=.*/INTERFACESv4=\"$IFACE\"/" /etc/default/isc-dhcp-server

# Reiniciamos el servicio DHCP
systemctl restart isc-dhcp-server

#Hacemos backup del archivo de configuración DHCP
cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.bak

