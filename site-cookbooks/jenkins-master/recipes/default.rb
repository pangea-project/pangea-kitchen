#
# Cookbook Name:: jenkins-master
# Recipe:: default
#
# Copyright 2015, Harald Sitter <sitter@kde.org>
#
# All rights reserved - Do Not Redistribute
#

service 'jenkins' do
  action :nothing
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

package 'install-native-gem-dependencies' do
  package_name [
    # various
    'libgmp-dev',
    # gem 'rugged'
    'cmake',
    'pkg-config'
  ]
end

package 'install-test-runtime-dependencies' do
  # Cloc is used for line counting!
  package_name %w(
    devscripts
    debhelper
    pkg-kde-tools
    cloc
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
