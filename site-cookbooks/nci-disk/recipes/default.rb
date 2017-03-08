directory '/mnt/volume-neon-jenkins' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

filesystem "volume-neon-jenkins" do
  fstype "ext4"
  device "/dev/disk/by-id/scsi-0DO_Volume_volume-neon-jenkin"
  mount "/mnt/volume-neon-jenkins"
  action [:create, :enable, :mount]
end

directory '/mnt/volume-neon-jenkins/workspace' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

mount '/var/lib/jenkins/workspace' do
  device '/mnt/volume-neon-jenkins/workspace'
  fstype 'none'
  options 'bind'
  action :enable
end
