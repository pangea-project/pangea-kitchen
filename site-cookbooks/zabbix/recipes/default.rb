#
# Cookbook Name:: zabbix
# Recipe:: default
#
# Copyright 2015-2018, Harald Sitter <sitter@kde.org>
#
# All rights reserved - Do Not Redistribute
#

service 'zabbix-agent' do
  action %i[stop disable]
  ignore_failure true
end

apt_package 'zabbix-agent' do
  action :purge
end

directory '/etc/zabbix' do
  recursive true
  action :delete
end
