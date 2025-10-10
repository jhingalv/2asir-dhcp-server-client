# 2 ASIR - DHCP - Practice A (Client/Server)

## Authors of the project

- **Juan Amador Hinojosa Gálvez** – [jhingal3010@ieszaidinvergeles.org](mailto:jhingal3010@ieszaidinvergeles.org)
- **Álvaro Rodríguez Pulido** – [arodpul3005@ieszaidinvergeles.org](mailto:arodpul3005@ieszaidinvergeles.org)

## Practice Objective

Set up a virtualized environment with three virtual machines, using Vagrant in a Linux environment. The virtual machines must comply with the next requirements:

- **DHCP Server (sv)** that assigns network configurations automatically.
- **Client 1 (c1)** that receives its network configuration via DHCP.
- **Client 2 (c2)** that gets a fixed IP address based on its MAC address.



## Network Structure

- External (host-only) network: `192.168.56.0/24`
  - **Server**: static IP `192.168.56.10`
- Internal network: `192.168.57.0/24`
  - **Server**: static IP `192.168.57.10`
  - **c1:** DHCP IP.
  - **c2:** DHCP IP based on MAC address.


## DHCP Server Configuration

- Network: `192.168.57.0/24`
- Dynamic range: `192.168.57.25 - 192.168.57.50`
- Broadcast address: `192.168.57.255`
- Gateway: `192.168.57.10`
- DNS Servers: `8.8.8.8` and `4.4.4.4`
- Domain name: `micasa.es`
- Default lease time: `1 day`
- Maximum lease time: `8 days`
  
**MAC address configuration (for Client 2):**
- MAC: `08:00:27:c2:c2:c2`
- Fixed address: `192.168.57.4`
- Default lease time: `1 hour`


## Client Configuration
- Network mode: `Internal Network`
- DHCP: `Enabled`
- Obtain dynamically new IP address command:
```bash
sudo dhclient
```
- Logs: `/var/log/syslog`
- Leases file: `/var/lib/dhcp/dhcp.leases`


## Prerequisites

- [Vagrant](https://www.vagrantup.com/)
- [VirtualBox](https://www.virtualbox.org/)
- Recommended base box: `ubuntu/jammy64`


## Files found in this repository
- **Vagrantfile:** Defines the virtual machines that will be created, with their network configuration:
```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"

  # 2GB of RAM to avoid issues at startup
  config.vm.provider "virtualbox" do |vb|
    vb.memory = 2048
  end

  # DHCP SERVER (sv)
  config.vm.define "dhcp-sv" do |dhcpsv|
    dhcpsv.vm.hostname = "dhcp-sv.izv.dhcp-sv-cli"

    # Host-only network (192.168.56.0/24) with Internet
    dhcpsv.vm.network "private_network", 
                      ip: "192.168.56.10"

    # Internal network (192.168.57.0/24), isolated for DHCP
    dhcpsv.vm.network   "private_network",
                      ip: "192.168.57.10",
                      virtualbox__intnet: "dhcp-sv-cli_net"

    dhcpsv.vm.provision "shell", path: "provision-dhcpsv.sh"
  end #dhcpsv

  # DHCP CLIENT 1 (c1)
  config.vm.define "dhcp-c1" do |dhcpc1|
    dhcpc1.vm.hostname = "dhcp-c1.izv.dhcp-sv-cli"

    # Internal network (192.168.57.0/24), isolated for DHCP
    dhcpc1.vm.network "private_network",
                      type: "dhcp",
                      virtualbox__intnet: "dhcp-sv-cli_net"
    
    dhcpc1.vm.provision "shell", path: "provision-dhcpc.sh"
  end #dhcpc1
  
  # DHCP CLIENT 2 (c2)
  config.vm.define "dhcp-c2" do |dhcpc2|
    dhcpc2.vm.hostname = "dhcp-c2.izv.dhcp-sv-cli"

    # Internal network (192.168.57.0/24), isolated for DHCP
    dhcpc2.vm.network "private_network",
                  type: "dhcp",
                  virtualbox__intnet: "dhcp-sv-cli_net",
                  mac: "080027c2c2c2"

    dhcpc2.vm.provision "shell", path: "provision-dhcpc.sh"
  end

end #Vagrant.configure
```

- **.gitignore:** It contains the files that will be ignored by the version control system.
- **LICENSE:** Defines the license of our project, to determine how can be used.
- **provision-dhcpc.sh:** Script for the DHCP configuration for virtual machine that runs the client 1:
```bash
#!/bin/bash

# Show the console lines to see possible errors
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

# Fix permissions on Netplan to avoid warnings
chmod 600 /etc/netplan/01-netcfg.yaml
chown root:root /etc/netplan/01-netcfg.yaml
chmod 600 /etc/netplan/50-vagrant.yaml
chown root:root /etc/netplan/50-vagrant.yaml

# Apply the config
netplan apply

# Restart the interface to ensure that it takes DHCP
ip link set "$IFACE" down
ip link set "$IFACE" up

# Force DHCP request (just in case)
dhclient -v "$IFACE"

# Check network config to verify the asigned IP
ip a
```
- **provision-dhcpsv.sh:** Script for the installation and management of the DHCP server and the client 2 MAC configuration:
```bash
#!/bin/bash

# Show the console lines to see possible errors
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

# Add the DHCP config

cat > /etc/dhcp/dhcpd.conf <<EOF
default-lease-time 86400;   # 1 day
max-lease-time 691200;      # 8 days
authoritative;              # As it is the only DHCP server

# General DHCP config
subnet 192.168.57.0 netmask 255.255.255.0 {
  range 192.168.57.25 192.168.57.50;
  option routers 192.168.57.10;
  option subnet-mask 255.255.255.0;
  option broadcast-address 192.168.57.255;
  option domain-name-servers 8.8.8.8, 4.4.4.4;
  option domain-name "micasa.es";
}

# Fixed IP for VM c2
host c2 {
  hardware ethernet 08:00:27:c2:c2:c2;
  fixed-address 192.168.57.4;
  default-lease-time 3600;  # 1 hour
  option domain-name-servers 1.1.1.1;
}
EOF

# Restart and enable the DHCP service to apply changes
systemctl restart isc-dhcp-server.service
systemctl enable isc-dhcp-server.service

# Check that the service is running properly
systemctl status isc-dhcp-server.service --no-pager # --no-pager avoids interruptions

# Check network config to verify IPs
ip a

# Check that the socket is listening
ss -lun
```


## Project Initialization

Initialize the project with the command:

```bash
vagrant up
```
Connect to the VM:
```bash
Vagrant ssh *MACHINE NAME*
```
Check if the clients obtain the network correctly with the configuration shown above:
```bash
ip a
```
Request/Renew lease:
```bash
sudo dhclient
sudo dhclient -r
```


## Error handling

If the DHCP service does not start or clients fail to obtain an IP address, follow these steps to identify and resolve issues:

1. **Check the syntax of the configuration file:**
```bash
sudo dhcpd -t
# (Validates /etc/dhcp/dhcpd.conf and reports syntax errors.)
```

2. **Inspect service status and logs:**
```bash
sudo systemctl status isc-dhcp-server.service
sudo journalctl -u isc-dhcp-server --no-pager | tail -n 20
# (Look for messages containing dhcpd: that may indicate parsing errors, invalid subnets, or missing options.)
```

3. **Verify network interface:**
```bash
grep INTERFACESv4 /etc/default/isc-dhcp-server
ip a
ss -lun | grep 67
# (Ensure that the service is listening on the correct interface (UDP port 67).)
```

4. **Check client connectivity:**
```bash
sudo dhclient -r
sudo dhclient -v
# (Then, on the server, review /var/log/syslog for messages like DHCPDISCOVER, DHCPOFFER, or DHCPACK.)
```

5. **Restore backup configuration:**
```bash
sudo cp /etc/dhcp/dhcpd.conf.bak /etc/dhcp/dhcpd.conf
sudo systemctl restart isc-dhcp-server
# (Use this if configuration errors prevent the service from starting.)
```