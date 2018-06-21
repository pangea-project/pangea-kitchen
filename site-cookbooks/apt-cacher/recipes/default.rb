#
# Cookbook Name:: apt-cacher
# Recipe:: default
#
# Copyright 2017-2018, Harald Sitter
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

# Calculate a suitable default size for the maximum cache use.
# The package stupidly hardcodes 40G as cache size. Apparently math is rocket
# science and determining what the maximum size of /var is cannot be done.
# Or can it...
# NOTE: this node attribute structure was introduced in Chef 13. This Cookbook
#  requires chef >= 13 because of this line.
root_values = node['filesystem']['by_mountpoint']['/mnt/volume-do-cacher-mirror']
root_size_mb = root_values['kb_size'].to_i / 1024.0 # Squid uses MiB
# Leave very little space. It's not clear if squid requires wiggle room.
max_cache_size = (root_size_mb * 0.99).to_i

package 'squid-deb-proxy'

apt_package %w[apt-cacher-ng avahi-daemon] do
  # apt-acher-ng was used previously but turned out a bit shitty, so we force
  # a migration to squid instead.
  #
  # squid-deb-proxy registers an avahi service and we can't do anything about
  # that but remove avahi entirely. Not useful anyway.
  # NOTE: the service also means stopping squid shits its pants, so we need
  #   to disable it so get the stupid squid-deb-proxy service to properly stop
  action :purge
end

ruby_block 'twiddle squid-deb-proxy.conf' do
  block do
    file = Chef::Util::FileEdit.new('/etc/squid-deb-proxy/squid-deb-proxy.conf')
    # Undo a stupid change previously done.
    file.search_file_replace_line(/^\s*http_access allow to_archive_mirrors/,
                                  'http_access deny !to_archive_mirrors')
    file.search_file_replace_line(%r{cache_dir aufs /var/cache/squid-deb-proxy},
                                  "cache_dir aufs /var/cache/squid-deb-proxy #{max_cache_size} 16 256")
    file.write_file
  end
end

# Bind the mirror block storage into the cache location. The cache path is
# hardcoded in various locations, so we can't simply change it.
mount '/var/cache/squid-deb-proxy' do
  device '/mnt/volume-do-cacher-mirror'
  fstype 'none'
  options 'bind'
  action :enable # don't auto-mount the bugger, it'd keep mounting over the bind
end

# This is very specific custom workaround bullshit.
# squid-deb-proxy uses upstart and doesn't actually properly shut down squid!
# To get working shutdown etc we use a custom systemd service. This is
# using part of the deb-proxy init-common rigging to concat directory acls
# and manages squid properly via -k.
# Should the init-common stuff change substantially this may either set up
# incomplete or fail entirely. Not much to be done alas.
systemd_unit 'squid-deb-proxy.service' do
  content <<-EOF
[Unit]
Description=squid-deb-proxy

[Service]
ExecStartPre=/bin/bash -c '. /usr/share/squid-deb-proxy/init-common.sh; pre_start'
ExecStart=/usr/sbin/squid -N -f /etc/squid-deb-proxy/squid-deb-proxy.conf
ExecStartPost=/bin/bash -c '. /usr/share/squid-deb-proxy/init-common.sh; post_start'
ExecStop=/usr/sbin/squid -k shutdown -f /etc/squid-deb-proxy/squid-deb-proxy.conf
ExecReload=/bin/bash -c '. /usr/share/squid-deb-proxy/init-common.sh; pre_start'
ExecReload=/usr/sbin/squid -k reconfigure -f /etc/squid-deb-proxy/squid-deb-proxy.conf

[Install]
WantedBy=multi-user.target
  EOF
  action %i[create enable restart]
end

systemd_unit 'squid.service' do
  # Disable regular squid, we don't need it
  action %i[disable stop]
end

file '/etc/squid-deb-proxy/mirror-dstdomain.acl.d/0-neon' do
  # NB: the concatenation helper of init-common is shitty and needs a \n to
  #    not break the concatenated file
  content ".archive.neon.kde.org\n.metadata.neon.kde.org\n.neon.plasma-mobile.org\n.repo.halium.org\n"
  notifies :reload, 'systemd_unit[squid-deb-proxy.service]', :immediately
end

file '/etc/squid-deb-proxy/allowed-networks-src.acl.d/0-blue-systems' do
  # NB: the concatenation helper of init-common is shitty and needs a \n to
  #    not break the concatenated file
  content <<-CONTENT
# private networks
10.0.0.0/8
172.16.0.0/12
192.168.0.0/16
127.0.0.1

# IPv6 private addresses
fe80::/64
::1/128

# BS farm
46.101.118.115 # drax (public DO)
147.75.32.190 # armhf builder (packet)
147.75.105.102 # arm64 builder (packet)
207.154.244.6 # mobile.neon.pangea.pub (mci)
207.154.251.179 # torvald (neon storage)
147.75.82.195 # openqa node (packet)

  CONTENT
  notifies :reload, 'systemd_unit[squid-deb-proxy.service]', :immediately
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
  variables server_name: server_name, document_root: document_root,
            proxy_port: 8000
  # Reload apache immediately so the vhost is up and running by the time
  # certbot does its thing.
  notifies :reload, 'service[apache2]', :immediately
end

apache_site server_name do
  enable true
end
