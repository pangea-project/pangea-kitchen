#
# Cookbook Name:: jenkins-master
# Recipe:: default
#
# Copyright 2015, Harald Sitter <sitter@kde.org>
#
# All rights reserved - Do Not Redistribute
#

# Make sure jenkins::master is run from global cookbook, so we have a
# fully provisioned jenkins.
include_recipe 'jenkins::master'

service 'jenkins' do
  action :stop
end

# Adjust the UID and GID to match what the containers use.
group 'jenkins' do
  action :modify
  gid 120
  notifies :restart, 'service[jenkins]', :delayed
end

user 'jenkins' do
  action :modify
  uid 100_000
  gid 120
  notifies :restart, 'service[jenkins]', :delayed
end

subid_set 'jenkins-subids' do
  username 'jenkins'
  uid 100_000
  groupname 'jenkins'
  gid 120
end

ruby_block 'chown jenkins dirs' do
  block do
    %w(/var/lib/jenkins /var/cache/jenkins /var/lib/jenkins-slave).each do |dir|
      stamp = "#{dir}/chef_jenkins-master-chown.stamp"
      next unless File.exist?(dir)
      next if File.exist?(stamp)
      paths = Dir["#{dir}/**/**"] + [dir]
      paths.select! { |pt| !pt.include?('workspace') || pt.include?('cache') }
      FileUtils.chown('jenkins', 'jenkins', paths)
      FileUtils.touch(stamp)
      FileUtils.chown(100_000, 120, stamp)
    end
  end
  notifies :restart, 'service[jenkins]', :delayed
end

directory '/var/lib/jenkins/init.groovy.d' do
  owner 'jenkins'
  group 'jenkins'
  mode '0755'
  action :create
end

cookbook_file '/var/lib/jenkins/init.groovy.d/cli-shutdown.groovy' do
  source 'cli-shutdown.groovy'
  owner 'jenkins'
  group 'jenkins'
  mode '0644'
  action :create
  notifies :restart, 'service[jenkins]', :delayed
end

package 'install-native-gem-dependencies' do
  package_name [
    # various
    'libgmp-dev',
    # gem 'rugged'
    'cmake',
    'pkg-config',
    ## ssh support weeh weeh
    'libssh2-1-dev'
  ]
end

package 'install-test-runtime-dependencies' do
  # Cloc is used for line counting!
  package_name %w(
    devscripts
    debhelper
    pkg-kde-tools
    cloc
    quilt
    patchutils
    cdbs
  )
end

package 'install-tooling-runtime-dependencies' do
  package_name %w(
    bzr
    debhelper
    devscripts
    git
  )
end

docker_installation_script 'default' do
  repo 'main'
  action :create
end

docker_service 'default' do
  action :restart
  # Masters are at present not subuid as we need full access
  # userns_remap '100000:120'
end

mount '/mnt/volume-neon-jenkins' do
  device '/dev/sda1'
  fstype 'ext4'
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
