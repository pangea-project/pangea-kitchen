#
# Cookbook Name:: jenkins-slave
# Recipe:: default
#
# Copyright 2015, Harald Sitter <sitter@kde.org>
#
# All rights reserved - Do Not Redistribute

slave_home = '/var/lib/jenkins-slave'

include_recipe 'jenkins-slave::ruby' if
  Chef::VersionConstraint.new('< 16.04').include?(node['platform_version'])

include_recipe 'user'
include_recipe 'openssh'

user_account 'jenkins-slave' do
  ssh_keys [
    'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDgWtfEVwpqGHHO0JJ3d45wVnobPgexqmRslxbwYj6AuheLxwVdWtZapz+en4+Op9ZS6D70VXW0OmJG7xHaMAq87ZjMcozpp/ez2tUyIpQ3G5Ge7gq/hbhCz+K98pun56ECdhYrQEE/o5jVmG1mfrPDvTGm85PYNrdUVL97PmnOT7aiE58Ljv1EbbSaf/BxjPXrNACZcwmE2WeUJ2jo0wR4KpNIidTfJ/TSy571aX3YO30q8WzuFsTUUt8XQQvKt6r3wGiK9OEGuKjn3OaN6RDxqd/9JvJs700biYx9zmoE8Qmx2cjO5hXREIhEKf1yxtNppXj8A+RAL4+qC7PLzjMV jenkins@rassilon',
    'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCsObI0X6VxK1/rwxIW3NDhKnLKpJJAHHBVHg1Iu/vjJba4cYBtW7KLz/9oryUDPuAdr9SegnnrZU9UMfiEv45tPJJvuJaKo8KYP1h1RHWNQF+1L5hfIahJ4tGdbF+SwPubWQV+K0JdGOD5pTnOXvwkpPgUDWdvfH7deSqlHfm+mmmrrtE2Rh9RE9cGnd0/nGoKlOOTXEWieNPFjEi2TFnYipCxJPPSE0O75ezpvKt5z2TLxLC4fAq1UlbtmV52/LdCdF5x7cE/BcXKJovqcSJ5cmNNetUCbiZDNtjhvg+j16hQquxd63gmteAQZZtkRGv+C7mswTiOjIR76NKexQIF jenkins@taspar',
    'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCiLBt3u8Ldo3/bwIYI3t4QZ8yW7lMdWLy92gOxk0er5Rb1baKvubFIfTRL18I4FCvYJyzchCGZhxFfCkO5FiKNhOlKWbPJRKgitj1y6t02Jlyw0Z+zQXKe1srpwwQa2iN1LuTINcRoun/+Ouq52uQeRaye9zV3ikT+53/GcsfJTgxkJN2IOpIaLdEA3epuqnStpXdGYvAjycUngbVJASHWXsZUCPtZK6acxoxHvFPdroEVs+rB3HdWFUoaFECRJ8LQo21p7qlFIeC03scUmYs2cDaBne8h0NhA9q/0o+HQqaf2zam8fJiMqKo3eTYUt6jRStzxT+tpg3zyDlKsipL/ jenkins@drax'
  ]
  home slave_home
  ssh_keygen false
  create_group false
  uid 100_000
end

group 'jenkins-slave' do
  action :create
  append true
  members %w(jenkins-slave)
  gid 120
end

subid_set 'jenkins-subids' do
  username 'jenkins-slave'
  uid 100_000
  groupname 'jenkins-slave'
  gid 120
end

kernel_module 'loop'

group 'docker' do
  action :modify
  append true
  members %w(jenkins-slave)
end

ruby_block 'chown jenkins dirs' do
  block do
    %w(/var/lib/jenkins /var/cache/jenkins /var/lib/jenkins-slave).each do |dir|
      stamp = "#{dir}/chef_jenkins-master-chown.stamp"
      next unless File.exist?(dir)
      next if File.exist?(stamp)
      paths = Dir["#{dir}/**/**"] + [dir]
      paths.select! { |pt| !pt.include?('workspace') || pt.include?('cache') }
      FileUtils.chown('jenkins-slave', 'jenkins-slave', paths)
      FileUtils.touch(stamp)
      FileUtils.chown(100_000, 120, stamp)
    end
  end
end

package 'install-native-gem-dependencies' do
  package_name [
    # various
    'libgmp-dev',
    # gem 'rugged'
    'cmake',
    'pkg-config',
    ## ssh support weeh weeh
    'libssh-dev'
  ]
end

execute 'lxc-docker purge' do
  command "apt purge -y --force-yes -o Dpkg::Options::='--force-confold'" \
          " -o Dpkg::Options::='--force-all'" \
          ' lxc-docker lxc-docker-*'
end

docker_installation_script 'default' do
  repo 'main'
  action :create
end

docker_service 'default' do
  action :restart
  userns_remap '100000:120'
end
