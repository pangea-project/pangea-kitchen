#
# Cookbook:: neon-image-syncd
# Recipe:: daemon
#
# Copyright:: 2017,  Harald Sitter
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

username = 'neon-image-syncd'
groupname = username.clone
userhome = "/home/#{username}/"
gopath = userhome

systemd_dir = '/etc/systemd/system'
# We are not using socket activation for now.
systemd_units = %w[neon-image-syncd.service]

importpath = 'invent.kde.org/sysadmin/neon-image-syncd.git'
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

# Go deployment
package 'golang-go'
bash "Installing go(#{File.basename(importpath)})" do
  code "go get -v -u #{importpath}"
  user username
  group groupname
  environment('GOPATH' => gopath, 'HOME' => userhome)
end
link "#{gopath}/bin/#{File.basename(importpath, '.git')}" do
  to "#{gopath}/bin/#{File.basename(importpath)}"
  owner username
  group groupname
  only_if { importpath.end_with?('.git') }
end

file "#{userhome}/sync" do
  mode '0755'
  owner username
  group groupname
  content <<-CONTENT
#!/bin/sh
ruby #{srcdir}/client.rb http://localhost:8080/v1/sync
  CONTENT
end

execute 'daemon-reload' do
  command 'systemctl daemon-reload'
  action :nothing
end

systemd_units.each do |unit_name|
  file "#{systemd_dir}/#{unit_name}" do
    content lazy { File.read("#{srcdir}/systemd/#{unit_name}") }
    notifies :run, 'execute[daemon-reload]', :immediately
  end

  systemd_unit unit_name do
    action [:enable, :start]
  end
end
