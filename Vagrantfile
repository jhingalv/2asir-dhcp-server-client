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
  end #dhcpsv

  # DHCP CLIENT 1 (c1)
  config.vm.define "dhcp-c1" do |dhcpc1|
    dhcpc1.vm.hostname = "dhcp-c1.izv.dhcp-sv-cli"

    # Internal network (192.168.57.0/24), isolated for DHCP
    dhcpc1.vm.network "private_network",
                      type: "dhcp",
                      virtualbox__intnet: "dhcp-sv-cli_net"
      end #dhcpc1
  
  # DHCP CLIENT 2 (c2)
  config.vm.define "dhcp-c2" do |dhcpc2|
    dhcpc2.vm.hostname = "dhcp-c2.izv.dhcp-sv-cli"

    # Internal network (192.168.57.0/24), isolated for DHCP
    dhcpc2.vm.network "private_network",
                  type: "dhcp",
                  virtualbox__intnet: "dhcp-sv-cli_net",
                  mac: "080027c2c2c2"
  end #dhcpc2

  # Ansible provisioning
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "playbook.yml"
    ansible.inventory_path = "inventory.yml"
    ansible.verbose = "v"
  end #ansible.provision

end #Vagrant.configure
