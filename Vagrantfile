# -*- mode: ruby -*-
# vi: set ft=ruby :

# VBox compatible uuid string parser. Eats uuid string and splits into 32bit
# integer array.
class RTUUID
  attr_reader :au32_s

  def initialize(string)
    # NB: VBox uses little endian for the first 3 ints but network (i.e. big)
    #     for the last int as documented in VBox' types.h
    #     As a consequence we'll have to do an endian flip of the string
    #     UUID so that our au32[3] == vbox' au32[3].
    hex = string.delete('-')
    # This is a tad convoluted.
    # Pack the hex chars into a binary blob and then unpack that blob as network
    # integers (big endian)
    ints = [hex].pack('h*').unpack('N*')
    # Then pack them again but this time flip the 4th integer to little endian.
    # NOTE: this doesn't actually do anything other than toggling the endian of
    #       the last integer.
    # For convenience do not unpack into one long hex string but a split array
    # of the 4 integers.
    @au32_s = ints.pack('NNNL<').unpack('h8h8h8h8')
  end
end

# VBox hacky module.
module VBox
  module_function

  def medium_by_id(medium)
    data = `vboxmanage showmediuminfo #{medium}`
    return '' unless $?.success?

    # VBox sets the device ID internally and we can't control this, the format
    # is ata-VBOX_HARDDISK_VB$UUID where $UUID is built thusly:
    #   RTStrPrintf(szSerial, sizeof(szSerial), "VB%08x-%08x", Uuid.au32[0],
    #               Uuid.au32[3]);
    # au32 in this case refers to a uint32[4] of the 128bit UUID.
    uuid = RTUUID.new(data.match(/^UUID\:\s*([a-z0-9\-]+)/).captures[0])
    "ata-VBOX_HARDDISK_VB#{uuid.au32_s[0]}-#{uuid.au32_s[3]}"
  end
end

volume = "#{__dir__}/.vagrant-volumes/do-volume-neon-jenkins.vdi"

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
