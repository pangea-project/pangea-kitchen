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
  uri 'http://repo.zabbix.com/zabbix/2.2/ubuntu'
  distribution node['lsb']['codename']
  components ['main']
  keyserver 'keyserver.ubuntu.com'
  key '7E1DEF85'
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
  content 'ServerActive=46.101.162.153'
  mode '0644'
  owner 'root'
  group 'root'
end

file '/etc/zabbix/zabbix_agentd.d/Server.conf' do
  content 'Server=46.101.162.153'
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

service 'zabbix-agent' do
  action :restart
end
