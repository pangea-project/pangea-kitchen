volume_dev_by_id = '/dev/disk/by-id/scsi-0DO_Volume_volume-neon-jenkins'

# Ad-hoc provision the needed vagrant volumes if applicable. This depends on
# outside vagrantfile rigging to write a disk-id file which contains the disk-id
# we have inside the virtual machine.
vagrant_disk_id_path =
  '/vagrant/.vagrant-volumes/do-volume-neon-jenkins.vdi.disk-id'
link volume_dev_by_id do
  to lazy {
    # Chef only supports single level symlinks in a device, since we only know
    # the by-id of the device inside vbox we'd have two levels and make chef
    # fall apart when trying to decide whether the device needs mounting.
    # To avoid this lazy eval our by-id to the actual device file.
    File.realpath("/dev/disk/by-id/#{File.read(vagrant_disk_id_path).strip}")
  }
  only_if do
    exist = File.exist?(vagrant_disk_id_path)
    if exist && File.read(vagrant_disk_id_path).strip.empty?
      raise 'There is a vagrant disk-id file but it is empty.' \
            ' Chances are the disk-id detection is broken.' \
            ' To fix this try running `vbox_volumes.rb` in the kitchen.'
    end
    exist
  end
end

directory '/mnt/volume-neon-jenkins' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

filesystem 'volume-neon-jenkins' do
  fstype 'ext4'
  device volume_dev_by_id
  mount '/mnt/volume-neon-jenkins'
  action [:create, :enable, :mount]
  options 'discard,defaults'
  force true # try to get round /dev/disk/by-id/scsi-0DO_Volume_volume-neon-jenkins is not a block special device
end

directory '/mnt/volume-neon-jenkins/workspace' do
  owner 'jenkins'
  group 'jenkins'
  mode '0755'
  action :create
end

mount '/var/lib/jenkins/workspace' do
  device '/mnt/volume-neon-jenkins/workspace'
  fstype 'none'
  options 'bind'
  action :enable
end
