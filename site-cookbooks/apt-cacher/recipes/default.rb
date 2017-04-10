#
# Cookbook Name:: apt-cacher
# Recipe:: default
#
# Copyright 2017, Harald Sitter
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

include_recipe 'apt::cacher-ng'

data_bag_path = Chef::Config[:data_bag_path]
security_conf = "#{data_bag_path}/cupboard/apt-cacher-ng/security.conf"
template '/etc/apt-cacher-ng/security.conf' do
  source security_conf
  local true
  owner 'root'
  group 'apt-cacher-ng'
  mode 0o640
  notifies :restart, 'service[apt-cacher-ng]'
end

template '/etc/apt-cacher-ng/optimize.conf' do
  source 'optimize.conf'
  owner 'root'
  group 'apt-cacher-ng'
  mode 0o640
  notifies :restart, 'service[apt-cacher-ng]'
end

# Wire into apache.

include_recipe 'apache2::default'
include_recipe 'apache2::mod_proxy'
include_recipe 'apache2::mod_proxy_http'
include_recipe 'apache2::mod_ssl'
include_recipe 'apache2::mod_headers'

server_name = 'apt.cache.pangea.pub'
document_root = "/var/www/#{server_name}"

directory document_root do
  owner 'www-data'
  group 'www-data'
end

template "#{node['apache']['dir']}/sites-available/#{server_name}.conf" do
  source "#{server_name}.conf.erb"
  owner 'root'
  group node['apache']['root_group']
  mode 0o644
  variables server_name: server_name, document_root: document_root
  # Reload apache immediately so the vhost is up and running by the time
  # certbot does its thing.
  notifies :reload, 'service[apache2]', :immediately
end

apache_site server_name do
  enable true
end

certbot_apache server_name do
  domains [server_name]
  email 'sitter@kde.org'
end
