#
# Cookbook Name:: jenkins-slave
# Recipe:: default
#
# Copyright 2015, Harald Sitter <sitter@kde.org>
#
# All rights reserved - Do Not Redistribute

slave_home = node['jenkins-slave']['user-home']

include_recipe 'user'

apt_repository 'ubuntu-updates' do
  uri 'http://ports.ubuntu.com/ubuntu-ports'
  distribution "#{node['lsb']['codename']}-updates"
  components ['main', 'universe']
  # Don't enable this for AMD64, required only for docker on ARM
  only_if { node['kernel']['machine'].start_with?('arm') }
end

user_account 'jenkins-slave' do
  ssh_keys [
    'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCiLBt3u8Ldo3/bwIYI3t4QZ8yW7lMdWLy92gOxk0er5Rb1baKvubFIfTRL18I4FCvYJyzchCGZhxFfCkO5FiKNhOlKWbPJRKgitj1y6t02Jlyw0Z+zQXKe1srpwwQa2iN1LuTINcRoun/+Ouq52uQeRaye9zV3ikT+53/GcsfJTgxkJN2IOpIaLdEA3epuqnStpXdGYvAjycUngbVJASHWXsZUCPtZK6acxoxHvFPdroEVs+rB3HdWFUoaFECRJ8LQo21p7qlFIeC03scUmYs2cDaBne8h0NhA9q/0o+HQqaf2zam8fJiMqKo3eTYUt6jRStzxT+tpg3zyDlKsipL/ jenkins@drax',
    'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDBpku8vqM0f8h7zbDY1Y8PwSbwdALWDVk0CeuZcvYhptU+bcsXEkkcGfZBxV+NWWXs+ygs8Ylsrn8RdtJLdCJzhZbSFVzZNL2VZEnzp1kfhcDp6Vqd5oJlggEdIpgnuamoEuXgrBgGraLDyJOLhZLvEAL2xlqeyWYrcZy4XYQAh6idKcIFciK1uEFvVATLdvPwPjIJ6PwRC9lHVXuwYhbnJEKT+/HeEzXWNvB02EQ0FmjfsbBIzYekh6bjz/Rq/anYCUE3PHQqrhljb2Bnz9MQKQXtCgdQ/mTipjcyssHTyr7/ptSTqpKsUkeGkonhLfnbFF8IA/+pYOf/UwWEnsAn jenkins@do-xenon-jenkins',
    'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDEieLzqqYRvTGJZA4RJXgTXymwXJmcQeAa3+R5b2j9OcVZoNHJs/V4fo9eKnlZ9oKhfvTe/8MEhBAfx10vi7EXb3c/44ubKBhf4d8P+v4Drq4EYzpBFgSLDogZD5EU6bvYnD3gMB7QN9/Slr7+TWQN3/VwEQ/9wohMUahzoLLmupvgNbFfswuiJQZsjOu3MCtq9omnc4wub3hckqZNZo6rHNc+MAXjCafBxDfWnJhs8fOdUiWuJfYEFkdmSK4xLVHBy48HCHm1YhoJIpdCgEJRb7DJzh9oM+cT9rt2g+1ESCJJs3FNLVjsE9r3As1sPbkPiwhNwJCVqY7PvaEUF2nDqtUegW9KGEP7TJ7HKEikzVwyO/faloWdD/iYdBH03h92Qgcv0+5EbQFvG77p7z43n4S89dKQOeOTJyVTAveFc88wNA5DbInx9WS/aMVqHZUI/+rLXniqpdiq5Jglbopw1W+MEfqhNOizQYc1X3HGS6Jcy9rzMHLfk1unvZyJu+ZwsMfre3TMzyct3ViSNuduK1/ky/7aqPpkFirs2vFB8MZAGLnnal2NcpYNHF2oML9V+FjSOsfLMfcWJUqF3yAPomvjRaivtJep+5MoBnnvND1uoMh6RKf2hmFbf9ZOGIXi/8vhUfz+AkLiSeLPq4qLivO7uPa2rV3m6tWm3YFXuQ== neon-builders@20190528',
    'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC0sFslLc5NhRQA7YNZ+FbH7vCY2diJNG7y2BgH3OJUHzbKIXJ8KaiYLo63o4cKeh0OknOA32qgq1OmkB8+WHp3AWXlw6KOVCo52WWa++D07jvNPynvQ2YAmxP4Y1K7rJznqd+Her6yoVE92Y3h4XJklL9kKlNxY59Rikzwy0cZVAil8wwxKePwN/Yg0TAjLoXt1NLyA+rbNFC/Dn1PhXZrbTkGu/oFmg+I8HfTuwJ6Rir485OYSpgMzGVdy/fqEOZqSppdtvYJyXcdcax24W7ghwL/woiC2+2eCziU+3Yan3wFSoGuCuJe+jph3kzeWZxI0tk9fnOsxQSL/CNX2AreomTXOneSNJrniD5i2Ls2I7lCgxsHmRnskGDCPJzpkRZDEnvwqn/nGPYoh0IeLtQ2ZiT7HwrX/2BzXpTcq15CnVTqWpZo3dyfDiga6MUJuYQu+LX9frPrCCz5ZWEUTEwnxDdlCVaVefJVUz7JQ+GA13MozBUql/it/a6USr4+fOtoE3JdZPp0hVXiNSG+w6ZD42dsJvEGgiM59zBZ5CW5lT4bp49WWMMoACYOHmw2KZLlJTv2nPgqXjykNofeGqTEYUrHLFatecsB9JhLxdAOZu8hV066AWW+IQ+gK/Qm97JN8gW0ryzyqbD7MGY5XwghYLR2o4zxdcDEKqCpKRNB5w== dci-jenkins@20190528',
    'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDjqnXGXWv2rBPflKJEPS9mipgglHzmSa1+kezl3oP+iCWw+NNwgDRAxOyOb7XDk8KtgwXZ2cQFJzSFzZucYB/Fv9Ebnp1u39109+TM3kTavi0GNa3gTgJ53fkaxif5osp5tf5VVerrEPYG01QvDOjdf+cQ5/sZhqxUAym5arCFsqBXBb5c8RxnQJms+U1ONDuQsz2KVlmJhJIuiKqQVPoUCGjh+c2nqNpExE22nKbUc3OpL+sng0/8iw1QJImqJ0UUM5W/tjJUJ1i3hxegg4RewAxlcNEBb0acMNgOOvg/m4Kvd+RbHq+0gCiAnzkUJsAGdzWjbgA45WwhVg1cSd8f jenkins@mci'
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
  gid 140
end

subid_set 'jenkins-subids' do
  username 'jenkins-slave'
  uid 100_000
  groupname 'jenkins-slave'
  gid 140
  # Even this is debatable... maybe we should stop this in general.
  not_if { node['jenkins-slave']['no-userns-remap'] }
end

# Backwards compat: previously all nodes always had the same path. These days
# that can be controlled through the user-home attribute. Pre-existing node
# configuration might have the legacy hardcoded path as workspace path
# configured though. To ensure they will work regardless we'll always make
# the legacy path so it may be used for workspaces even when the actual
# user home is elsewhere.
directory '/var/lib/jenkins-slave' do
  owner 'jenkins-slave'
  mode '0700'
  action :create
end

ruby_block 'chown jenkins dirs' do
  block do
    (%w(/var/lib/jenkins /var/cache/jenkins /var/lib/jenkins-slave) + [slave_home]).each do |dir|
      stamp = "#{dir}/chef_jenkins-master-chown.stamp"
      next unless File.exist?(dir)
      next if File.exist?(stamp)
      paths = Dir["#{dir}/**/**"] + [dir]
      paths.select! { |pt| !pt.include?('workspace') || pt.include?('cache') }
      FileUtils.chown('jenkins-slave', 'jenkins-slave', paths)
      FileUtils.touch(stamp)
      FileUtils.chown(100_000, 140, stamp)
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
    'libssh2-1-dev',
    # required for nokogiri
    'zlib1g-dev',
    # required for ffi
    'libffi-dev'
  ]
end

package 'aufs-tools'

package 'lxc-docker purge' do
  package_name %w(lxc-docker lxc-docker-*)
  action :purge
  options "--force-yes -o Dpkg::Options::='--force-confold' -o Dpkg::Options::='--force-all' --ignore-missing"
end

docker_installation_script 'default' do
  repo 'main'
  action :create
  only_if { node['kernel']['machine'].start_with?('x86_64') }
end

docker_installation_package 'default' do
  action :create
  package_name 'docker.io'
  if Chef::VersionConstraint.new('= 18.04').include?(node['platform_version'])
    package_version '17.12.1-0ubuntu1'
  else
    package_version '1.13.1-0ubuntu1~16.04.2'
  end
  not_if { node['kernel']['machine'].start_with?('x86_64') ||
    Chef::VersionConstraint.new('> 18.04').include?(node['platform_version']) }
end

docker_installation_package 'default' do
  action :create
  package_name 'docker-ce'
  not_if { node['kernel']['machine'].start_with?('x86_64') ||
    Chef::VersionConstraint.new('<= 18.04').include?(node['platform_version']) }
end

docker_service 'default' do
  action :start
  # Only remap unless disabled
  userns_remap node['jenkins-slave']['no-userns-remap'] ? nil : '100000:140'
end

group 'docker' do
  action :modify
  append true
  members %w[jenkins-slave]
end
