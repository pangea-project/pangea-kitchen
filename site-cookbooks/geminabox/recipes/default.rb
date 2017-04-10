#
# Cookbook Name:: geminabox
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

username = 'geminabox'
groupname = username.clone
userhome = "/home/#{username}/"
systemd_dir = "#{userhome}/.config/systemd/user"

repourl = 'https://github.com/blue-systems/pangea-geminabox'
clonedir = "#{userhome}/src"

ohai 'reload_passwd' do
  action :nothing
  plugin 'etc'
end

group groupname do
  action :create
end

user username do
  home userhome
  group groupname
  manage_home true
  action :create
  notifies :reload, 'ohai[reload_passwd]', :immediately
end

systemd_unit 'geminabox.service' do
  user username
  # action %i(reload disable)
end

systemd_unit 'geminabox.socket' do
  user username
  # action %i(enable restart)
  # notifies :restart, 'systemd_unit[geminabox.service]'
end

git clonedir do
  repository repourl
  user username
  group groupname
  action :sync
  # Delayed restart of the service iff the code changed.
  notifies :restart, 'systemd_unit[geminabox.service]'
end

include_recipe 'apache2::default'
include_recipe 'apache2::mod_proxy'
include_recipe 'apache2::mod_proxy_http'
include_recipe 'apache2::mod_ssl'

document_root = '/var/www/gem.cache.pangea.pub'
directory document_root do
  owner 'www-data'
  group 'www-data'
end

group 'www-data' do
  append true
  members [username]
  action :modify
  notifies :restart, 'systemd_unit[geminabox.socket]'
end

# Systemd setup
package %w(libpam-systemd dbus-user-session) # for session management via logind

execute 'enable-linger' do
  command "loginctl enable-linger #{username}"
end

execute 'daemon-reload' do
  command 'systemctl daemon-reload'
end

execute 'daemon-reload-user' do
  command 'systemctl --user daemon-reload'
  user username
  group groupname
  environment lazy {
    { 'DBUS_SESSION_BUS_ADDRESS' =>
      "unix:path=/run/user/#{node['etc']['passwd'][username]['uid']}/bus" }
  }
  action :nothing
end

#   The dbus-user-session installs a bus socket activation, but we need to make
#   sure the user service is being started so systemd controls the socket.
systemd_unit 'user@.service' do
  name lazy { "user@#{node.fetch('etc').fetch('passwd').fetch(username).fetch('uid')}.service" }
  action %i(restart start)
  not_if { File.exist?("/run/user/#{node.fetch('etc').fetch('passwd').fetch(username).fetch('uid')}/bus") }
end

#   systemd_unit would dump user stuff into /etc/user/... but there they'd still
#   be owned by root which is stupidly daft. So we bypass systemd_unit's create
#   action and instead do it manually in $HOME/.config/...
bash 'creating systemd user dir' do
  code "mkdir -pv #{systemd_dir}"
  creates systemd_dir
  user username
  group groupname
end

template "#{systemd_dir}/geminabox.socket" do
  source 'geminabox.socket.erb'
  owner username
  group groupname
  mode 0o600
  variables userhome: userhome, clonedir: clonedir
  notifies :run, 'execute[daemon-reload-user]', :immediately
  notifies :stop, 'systemd_unit[geminabox.service]'
  notifies :restart, 'systemd_unit[geminabox.socket]'
end

template "#{systemd_dir}/geminabox.service" do
  source 'geminabox.service.erb'
  owner username
  group groupname
  mode 0o600
  variables userhome: userhome, clonedir: clonedir
  # This notification is queued, on first convergence the socket will be first
  # in the queue, so this is ultimately noop. On subsequent convergences a
  # change to the service should always restart the service and a change to the
  # socket will always restart both.
  notifies :run, 'execute[daemon-reload-user]', :immediately
  notifies :enable, 'systemd_unit[geminabox.socket]'
  notifies :restart, 'systemd_unit[geminabox.socket]'
end

template "#{node['apache']['dir']}/sites-available/gem.cache.pangea.pub.conf" do
  source 'gem.cache.pangea.pub.conf.erb'
  owner 'root'
  group node['apache']['root_group']
  mode 0o644
  variables server_name: 'gem.cache.pangea.pub', userhome: userhome,
            document_root: document_root
  # Reload apache immediately so the vhost is up and running by the time
  # certbot does its thing.
  notifies :reload, 'service[apache2]', :immediately
end

apache_site 'gem.cache.pangea.pub' do
  enable true
end

certbot_apache 'geminabox' do
  domains %w[gem.cache.pangea.pub]
  email 'sitter@kde.org'
end
