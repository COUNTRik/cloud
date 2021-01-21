# -*- mode: ruby -*-
# vi: set ft=ruby :
VAGRANT_API_VERSION = "2"
VAGRANT_EXPERIMENTAL = "disks"

Vagrant.configure(VAGRANT_API_VERSION) do |config|
  config.vm.box = "centos/7"

  # config.vm.provision "ansible" do |ansible|
  #   ansible.verbose = "v"
  #   ansible.playbook = "ansible/playbook.yml"
  # end


  # config.vm.provider "virtualbox" do |v|
	 #  v.memory = 256
  # end

  config.vm.define "web" do |web|
    web.vm.network "private_network", ip: "192.168.50.10", virtualbox__intnet: "cloud"
    web.vm.hostname = "web"
    
    # web.vm.provider "virtualbox" do |vb|
    #   vb.cpu = 1
    #   vb.memory = 1024
    # end

    # web.vm.disk :disk, size: "100GB", primmary: true

  end

  config.vm.define "db" do |db|
    db.vm.network "private_network", ip: "192.168.50.11", virtualbox__intnet: "cloud"
    db.vm.hostname = "db"
    
    # db.vm.provider "virtualbox" do |vb|
    #   vb.cpu = 1
    #   vb.memory = 1024
    # end

    # db.vm.disk :disk, size: "100GB", primmary: true

  end

end
