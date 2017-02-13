#
# Cookbook Name:: zabbix
# Recipe:: default
#
# Copyright 2015, Harald Sitter <sitter@kde.org>
#
# All rights reserved - Do Not Redistribute
#

# Extracted information from
# http://repo.zabbix.com/zabbix/2.2/ubuntu/pool/main/z/zabbix-release/zabbix-release_2.2-1+trusty_all.deb
apt_repository 'zabbix' do
  uri 'http://repo.zabbix.com/zabbix/3.0/ubuntu'
  distribution node['lsb']['codename']
  components ['main']
  keyserver 'keyserver.ubuntu.com'
  # Old key was 'FBAB D5FB 2025 5ECA B22E  E194 D13D 58E4 79EA 5ED4'.
  # New key. There is no announcement but they are cross-signed so I am infering
  # no one gained access to the archive.
  key 'A184 8F53 52D0 22B9 471D  83D0 082A B56B A14F E591'.delete(' ')
  # Do not add this repo if the host is ARM. The repo has no ARM builds
  # so this would only lead to apt update erroring out.
  not_if { node['kernel']['machine'].start_with?('arm') }
end

# Cleanup from previously broken behavior. See above.
apt_repository 'zabbix' do
  action :remove
  only_if { node['kernel']['machine'].start_with?('arm') }
end

package 'Install Zabbix Agent' do
  package_name %w(zabbix-agent)
end

# On ARM we use archive packages, which have a different path. Because why
# wouldn't they...
ruby_block 'armhfsymlink' do
  block do
    if Dir.exist?('/etc/zabbix/zabbix_agentd.conf.d') &&
       !Dir.exist?('/etc/zabbix/zabbix_agentd.d')
      File.symlink('/etc/zabbix/zabbix_agentd.conf.d',
                   '/etc/zabbix/zabbix_agentd.d')
    end
  end
end

file '/etc/zabbix/zabbix_agentd.d/ServerActive.conf' do
  only_if { node.name != node['zabbix']['server']['node'] }
  content "ServerActive=#{node['zabbix']['server']['ipaddress']}"
  mode '0644'
  owner 'root'
  group 'root'
end

file '/etc/zabbix/zabbix_agentd.d/Server.conf' do
  only_if { node.name != node['zabbix']['server']['node'] }
  content "Server=#{node['zabbix']['server']['ipaddress']}"
  mode '0644'
  owner 'root'
  group 'root'
end

file '/etc/zabbix/zabbix_agentd.d/Hostname.conf' do
  content "Hostname=#{node.name}"
  mode '0644'
  owner 'root'
  group 'root'
end

file '/etc/zabbix/zabbix_agentd.d/HostMetadataItem.conf' do
  content 'HostMetadataItem=system.uname'
  mode '0644'
  owner 'root'
  group 'root'
end

file '/etc/zabbix/zabbix_agentd.d/UserParameter_updates.conf' do
  content 'UserParameter=ubuntu.updates,/usr/lib/update-notifier/apt-check 2>&1 | cut -f1 -d\;'
  mode '0644'
  owner 'root'
  group 'root'
end

file '/etc/zabbix/zabbix_agentd.d/UserParameter_security-updates.conf' do
  content 'UserParameter=ubuntu.security-updates,/usr/lib/update-notifier/apt-check 2>&1 | cut -f2 -d\;'
  mode '0644'
  owner 'root'
  group 'root'
end

# Bump the overall time, apt can be fairly slow so things can time out easily
# within the default 3 seconds.
file '/etc/zabbix/zabbix_agentd.d/Timeout.conf' do
  content 'Timeout=16'
  mode '0644'
  owner 'root'
  group 'root'
end

service 'zabbix-agent' do
  action :restart
end
