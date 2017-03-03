mount '/mnt/volume-neon-jenkins' do
  device '/dev/sda1'
  fstype 'ext4'
end

mount '/mnt/volume-neon-jenkins' do
  device '/dev/sda1'
  fstype 'ext4'
  action :enable
end

directory '/mnt/volume-neon-jenkins/jobs/' do
  owner 'jenkins'
  group 'jenkins'
  mode '0755'
  action :create
end

link '/var/lib/jenkins/jobs' do
  owner 'jenkins'
  group 'jenkins'
  to '/mnt/volume-neon-jenkins/jobs/'
end
