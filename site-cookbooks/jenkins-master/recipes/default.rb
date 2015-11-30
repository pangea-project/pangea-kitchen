#
# Cookbook Name:: jenkins-master
# Recipe:: default
#
# Copyright 2015, Harald Sitter <sitter@kde.org>
#
# All rights reserved - Do Not Redistribute
#

service 'jenkins' do
  action :stop
end

# Adjust the UID and GID to match what the containers use.
group 'jenkins' do
  action :modify
  gid 120
end

ruby_block 'armhfsymlink' do
  block do
    puts File.read('/etc/passwd')
    puts File.read('/etc/group')
    puts `ls -lah /var/lib/`
  end
end

user 'jenkins' do
  action :modify
  uid 100_000
  gid 120
end

%w(/var/lib/jenkins /var/cache/jenkins /var/lib/jenkins-slave).each do |dir|
  next unless File.exist?(dir)
  stamp = "#{dir}/chef_jenkins-master-chown.stamp"
  next if File.exist?(stamp)
  paths = Dir["#{dir}/**/**"] + [dir]
  paths.each do |path|
    # Do not mangle workspace permissions as they can be different due to
    # lack of subuid in docker.
    next if path.include?('workspace')
    file path do
      owner 'jenkins'
      group 'jenkins'
    end if File.file?(path)
    directory path do
      owner 'jenkins'
      group 'jenkins'
    end if File.directory?(path)
  end
  file stamp do
    content ''
    mode '0644'
    owner 'jenkins'
  end
end

service 'jenkins' do
  action :restart
end

package 'Install native gem dependencies' do
  package_name %w(
    libgmp-dev
  )
end

package 'Install test runtime dependencies' do
  # Cloc is used for line counting!
  package_name %w(
    devscripts
    debhelper
    pkg-kde-tools
    cloc
  )
end
