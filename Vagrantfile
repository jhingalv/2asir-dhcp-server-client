# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  config.vm.define "dhcpsv" do |dhcpsv|
    dhcpsv.vm.hostname = "dhcpsv.izv.dhcpsvrcli"
    dhcpsv.vm.network "private_network", ip: "192.168.56.10"
    dhcpsv.vm.provision "shell", path: "provision-dhcpsv.sh"
  end #dhcpsv
end #Vagrant.configure
