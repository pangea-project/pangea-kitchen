mount '/mnt/volume-neon-jenkins' do
  device '/dev/sda1'
  fstype 'ext4'
end

mount '/mnt/volume-neon-jenkins' do
  device '/dev/sda1'
  fstype 'ext4'
  action :enable
end

mount '/var/lib/jenkins/workspace' do
  device '/mnt/volume-neon-jenkins/workspace'
  fstype 'none'
  options 'bind'
  action :enable
end
