# -*- mode: ruby -*-
# vi: set ft=ruby :
VAGRANT_API_VERSION = "2"

Vagrant.configure(VAGRANT_API_VERSION) do |config|
  config.vm.box = "centos/7"

  # config.vm.provision "ansible" do |ansible|
  #   ansible.verbose = "v"
  #   ansible.playbook = "ansible/playbook.yml"
  # end

  config.vm.define "web" do |web|
    # web.vm.network "private_network", ip: "192.168.50.10"
    web.vm.network "private_network", ip: "192.168.50.10", virtualbox__intnet: "local"
    web.vm.hostname = "web"
    
    web.vm.provider "virtualbox" do |vb|
      # vb.cpu = 1
      vb.memory = 1024
    end

  end

  config.vm.define "backup" do |backup|
    # backup.vm.network "private_network", ip: "192.168.50.12"
    backup.vm.network "private_network", ip: "192.168.50.12", virtualbox__intnet: "local"
    backup.vm.hostname = "backup"
    
    backup.vm.provider "virtualbox" do |vb|
      # vb.cpu = 1
      vb.memory = 1024
    end

  end

  config.vm.define "router" do |router|
    # router.vm.network "private_network", ip: "192.168.50.12"
    router.vm.network "private_network", ip: "192.168.50.12", virtualbox__intnet: "local"
    router.vm.hostname = "router"
    
    router.vm.provider "virtualbox" do |vb|
      # vb.cpu = 1
      vb.memory = 256
    end

  end

end
