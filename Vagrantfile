# -*- mode: ruby -*-
# vi: set ft=ruby :

unless Vagrant.has_plugin?('vagrant-persistent-storage')
  system('vagrant plugin install vagrant-persistent-storage') || raise
  warn 'Restarting...'
  exec($0, *ARGV)
end

require_relative 'vbox_volumes'

module VagrantPlugins::ProviderVirtualBox::Driver
  class Base
    prepend DiskIDWriter
  end
end

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # https://docs.vagrantup.com

  config.vm.box = 'ubuntu/trusty64'
  config.vm.network 'forwarded_port', guest: 80, host: 8181
  config.vm.network 'private_network', ip: '192.168.33.10'

  config.persistent_storage.enabled = true
  config.persistent_storage.location = VBox.volume
  config.persistent_storage.size = 32 # Megabytes
  config.persistent_storage.use_lvm = false
  config.persistent_storage.format = false
  config.persistent_storage.mount = false
  # This doesn't actually do shit.
  config.persistent_storage.diskdevice = VBox.medium_by_id(VBox.volume)

  config.vm.provider 'virtualbox' do |v|
    v.memory = 2048
    v.cpus = 4
  end

  config.vm.provision 'chef_zero' do |chef|
    chef.version = '13'
    chef.cookbooks_path = %w(cookbooks site-cookbooks)
    chef.roles_path = 'roles'
    chef.nodes_path = 'vagrant-nodes'
    chef.data_bags_path = 'data_bags'
    chef.add_role 'jenkins-master'
    chef.add_recipe 'nci-disk'
    chef.log_level = 'info'
  end
end
