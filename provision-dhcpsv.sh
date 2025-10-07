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

#Añadimos la configuración del DHCP al archivo
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

# Reiniciamos y habilitamos el servicio para aplicar la configuración
systemctl restart isc-dhcp-server.service
systemctl enable isc-dhcp-server.service

# Comprobamos que se ha iniciado correctamente
systemctl status isc-dhcp-server.service --no-pager # --no-pager evita interrupciones

# Comprobamos que el socket está escuchando
ss -lun