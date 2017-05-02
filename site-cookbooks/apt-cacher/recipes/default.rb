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

# Calculate a suitable default size for the maximum cache use.
# The package stupidly hardcodes 40G as cache size. Apparently math is rocket
# science and determining what the maximum size of /var is cannot be done.
# Or can it...
_root_dev, root_values = node['filesystem'].find { |_dev, f| f['mount'] == '/' }
root_size_mb = root_values['kb_size'].to_i / 1024.0 # Squid uses MiB
# We will use 75% of root for the cache, this should give us a good amount of
# space whilest not having much of a chance to impair other functions of
# the server.
max_cache_size = (root_size_mb * 0.75).to_i

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

file '/etc/squid-deb-proxy/mirror-dstdomain.acl.d/0-neon' do
  # NB: the concatenation helper of init-common is shitty and needs a \n to
  #    not break the concatenated file
  content ".archive.neon.kde.org\n"
end

ruby_block 'twiddle squid-deb-proxy.conf' do
  block do
    file = Chef::Util::FileEdit.new('/etc/squid-deb-proxy/squid-deb-proxy.conf')
    # Switch some weird crap around.
    # The config uses a double invert which has weird side effects WRT access
    # control to manage URI etc., change it to an allow (the config denies all,
    # so explicit allow combined with that should give the same result)
    file.search_file_replace_line(/http_access deny !to_archive_mirrors/,
                                  'http_access allow to_archive_mirrors')
    file.search_file_replace_line(%r{cache_dir aufs /var/cache/squid-deb-proxy},
                                  "cache_dir aufs /var/cache/squid-deb-proxy #{max_cache_size} 16 256")
    file.write_file
  end
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
ExecReload=/usr/sbin/squid -k reconfigure -f /etc/squid-deb-proxy/squid-deb-proxy.conf

[Install]
WantedBy=multi-user.target
  EOF
  action %i[create enable start]
end

systemd_unit 'squid.service' do
  # Disable regular squid, we don't need it
  action %i[disable stop]
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

certbot_apache server_name do
  domains [server_name]
  redirect false
  email 'sitter@kde.org'
end
