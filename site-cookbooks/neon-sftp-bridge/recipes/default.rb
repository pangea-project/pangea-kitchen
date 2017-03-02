#
# Cookbook Name:: neon-sftp-bridge
# Recipe:: default
#
# Copyright 2017, Harald Sitter
#
# All rights reserved - Do Not Redistribute
#

username = 'neon-sftp-bridge'
groupname = username.clone
userhome = "/home/#{username}/"
gopath = userhome
systemd_dir = "#{userhome}/.config/systemd/user"

importpath = 'anongit.kde.org/sysadmin/neon-sftp-bridge.git'
srcdir = "#{gopath}/src/#{importpath}"

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

directory "#{userhome}/.ssh" do
  owner username
  group groupname
  mode 0o700
end

data_bag_path = Chef::Config[:data_bag_path]
keys_dir = File.join(data_bag_path, 'cupboard', 'ssh-keys', node.name,
                     'neon-sftp-bridge')
keys = Dir.glob("#{keys_dir}/*").select { |x| !x.end_with?('.secret') }
raise "Couldn't find any ssh keys in #{keys_dir}" if keys.empty?
keys.each do |key_file|
  template "#{userhome}/.ssh/#{File.basename(key_file)}" do
    source key_file
    local true
    owner username
    group groupname
    mode 0o600
  end
end

# Go deployment
package 'golang-go'
bash 'Installing go(neon-sftp-bridge)' do
  code "go get -v -u #{importpath}"
  user username
  group groupname
  environment('GOPATH' => gopath)
end
link "#{gopath}/bin/neon-sftp-bridge" do
  to "#{gopath}/bin/neon-sftp-bridge.git"
  owner username
  group groupname
end

# Systemd setup
package %w(libpam-systemd dbus-user-session) # for session management via logind

execute 'enable-linger' do
  command "loginctl enable-linger #{username}"
end

execute 'daemon-reload' do
  command 'systemctl daemon-reload'
end

#   The dbus-user-session installs a bus socket activation, but we need to make
#   sure the user service is being started so systemd controls the socket.
systemd_unit 'user@.service' do
  name lazy { "user@#{node.fetch('etc').fetch('passwd').fetch(username).fetch('uid')}.service" }
  action [:restart, :start]
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

file "#{systemd_dir}/neon-sftp-bridge.service" do
  content lazy { File.read("#{srcdir}/neon-sftp-bridge.service") }
  owner username
  group groupname
  mode 0o600
  action :create
end

systemd_unit 'neon-sftp-bridge.service' do
  user username
  action [:reload, :enable, :start]
end
