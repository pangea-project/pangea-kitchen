volume_dev_by_id = '/dev/disk/by-id/scsi-0DO_Volume_volume-neon-jenkins'

# Ad-hoc provision the needed vagrant volumes if applicable. This depends on
# outside vagrantfile rigging to write a disk-id file which contains the disk-id
# we have inside the virtual machine.
vagrant_disk_id_path =
  '/vagrant/.vagrant-volumes/do-volume-neon-jenkins.vdi.disk-id'
link volume_dev_by_id do
  to "/dev/disk/by-id/#{File.read(vagrant_disk_id_path).strip}"
  only_if { File.exist?(vagrant_disk_id_path) }
end

directory '/mnt/volume-neon-jenkins' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

filesystem 'volume-neon-jenkins' do
  fstype 'ext4'
  device '/dev/disk/by-id/scsi-0DO_Volume_volume-neon-jenkins'
  mount '/mnt/volume-neon-jenkins'
  action [:create, :enable, :mount]
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
