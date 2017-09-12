#
# Cookbook:: neon_websites
# Recipe:: default
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

params = {
  # template: 'metadata.conf.erb',
  enable: true,

  server_name: 'metadata.neon.kde.org'
}

# application_name = params[:server_name]

# include_recipe 'apache2::default'

web_app params[:server_name] do
  server_name params[:server_name]
  directory_options %w[Indexes FollowSymLinks]
  docroot '/var/www/metadata'
  cookbook 'apache2'
  notifies :reload, 'service[apache2]', :immediately # reload immediately so we can certbot it
end

site_enabled = params[:enable]
apache_site params[:name] do
  enable site_enabled
end

certbot_apache params[:server_name] do
  domains [params[:server_name]]
  redirect true
  email 'sitter@kde.org'
end
