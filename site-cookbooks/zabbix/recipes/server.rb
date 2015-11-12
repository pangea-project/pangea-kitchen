#
# Cookbook Name:: zabbix
# Recipe:: default
#
# Copyright 2015, Harald Sitter <sitter@kde.org>
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'zabbix'

package 'Install Zabbix Server' do
  package_name %w(zabbix-server-mysql zabbix-frontend-php)
end

# mysql2_chef_gem 'default' do
#   action :install
# end
#
# mysql_database_user 'zabbix' do
#   connection host: '127.0.0.1',
#              username: 'root',
#              password: ''
#   password 'zabbix'
#   action :create
# end

ruby_block 'Twiddle timezone' do
  block do
    file = Chef::Util::FileEdit.new('/etc/apache2/conf-available/zabbix.conf')
    file.search_file_replace_line(/.*php_value date.timezone.*/,
                                  '    php_value date.timezone UTC')
    file.write_file
  end
end

service 'apache2' do
  action :restart
end

template '/etc/zabbix/web/zabbix.conf.php' do
  source 'zabbix.conf.php.erb'
  owner 'www-data'
  group 'www-data'
  mode '0644'
end

# Restart agent so it can poke the server
service 'zabbix-agent' do
  action :restart
end
