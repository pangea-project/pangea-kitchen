# -*- mode: ruby -*-
# vi: set ft=ruby :

require_relative 'vbox_volumes'

volume = VBox.volume

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # https://docs.vagrantup.com

  config.vm.box = 'ubuntu/trusty64'
  config.vm.network 'forwarded_port', guest: 80, host: 8181
  config.vm.network 'private_network', ip: '192.168.33.10'

  config.vm.provider 'virtualbox' do |v|
    v.memory = 2048
    v.cpus = 4

    unless File.exist?(volume)
      dir = File.dirname(volume)
      Dir.mkdir(dir) unless File.exist?(dir)
      size = 32 # Megabytes
      v.customize ['createmedium', '--filename', volume, '--size', size]
      File.write("#{volume}.disk-id", VBox.medium_by_id(volume))
    end
    v.customize ['storageattach', :id,
                 '--storagectl', 'SATAController',
                 '--port', 1, '--device', 0, '--type', 'hdd',
                 '--setuuid', '',
                 '--medium', volume]
  end

  config.vm.provision 'chef_zero' do |chef|
    chef.cookbooks_path = %w(cookbooks site-cookbooks)
    chef.roles_path = 'roles'
    chef.nodes_path = 'vagrant-nodes'
    chef.data_bags_path = 'data_bags'
    chef.add_recipe 'nci-disk'
    # chef.add_role 'jenkins-master'
    chef.log_level = 'info'
  end
end
