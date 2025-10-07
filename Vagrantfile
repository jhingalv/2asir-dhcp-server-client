# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"

  # DHCP SERVER
  config.vm.define "dhcp-sv" do |dhcpsv|
    dhcpsv.vm.hostname = "dhcp-sv.izv.dhcp-sv-cli"

    # Host-only network (192.168.56.0/24) with Internet
    dhcpsv.vm.network   "private_network", 
                        ip: "192.168.56.10"

    # Internal network (192.168.57.0/24), isolated for DHCP
    dhcpsv.vm.network   "private_network",
                        ip: "192.168.57.10",
                        virtualbox_intnet: "dhcp-sv-cli_net"

    dhcpsv.vm.provision "shell", path: "provision-dhcpsv.sh"
  end #dhcpsv

  # DHCP CLIENT 1
  config.vm.define "dhcp-c1" do |dhcpc1|
    dhcpc1.vm.hostname = "dhcp-c1.izv.dhcp-sv-cli"

    # Internal network (192.168.57.0/24), isolated for DHCP
    dhcpc1.vm.network   "private_network",
                        virtualbox_intnet: "dhcp-sv-cli_net",
                        autoconfig: false
    
    dhcpc1.vm.provision "shell", path: "provision-dhcpc1.sh"
  end #dhcpc1

end #Vagrant.configure
