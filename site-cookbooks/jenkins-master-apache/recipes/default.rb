#
# Cookbook Name:: jenkins-master-apache
# Recipe:: default
#
# Copyright 2016, Harald Sitter <sitter@kde.org>
#
# All rights reserved - Do Not Redistribute
#

params = {
  template: 'jenkins.conf.erb',
  local: false,
  enable: true,

  server_port: node['jenkins-master-apache']['server_port'],
  server_name: node['jenkins-master-apache']['server_name'],
  server_aliases: node['jenkins-master-apache']['server_aliases'],
  jenkinsroot: '/var/cache/jenkins',
  jenkinshome: '/var/lib/jenkins',
  document_root: "/var/www/#{node['jenkins-master-apache']['server_name']}"
}

application_name = params[:server_name]
params[:name] = params[:server_name]

include_recipe 'apache2::default'
include_recipe 'apache2::mod_proxy'
include_recipe 'apache2::mod_proxy_http'

directory params[:document_root] do
  owner 'www-data'
  group 'www-data'
end

template "#{node['apache']['dir']}/sites-available/#{application_name}.conf" do
  source params[:template]
  local params[:local]
  owner 'root'
  group node['apache']['root_group']
  mode '0644'
  cookbook params[:cookbook] if params[:cookbook]
  variables(
    application_name: application_name,
    params: params
  )
  notifies :reload, 'service[apache2]', :delayed
end

site_enabled = params[:enable]
apache_site params[:name] do
  enable site_enabled
  notifies :reload, 'service[apache2]', :immediately # needs to be for certbot
end

certbot_apache params[:server_name] do
  domains [params[:server_name]]
  email 'sitter@kde.org'
  webroot_path params[:document_root]
  only_if { site_enabled && node['jenkins-master-apache']['certbot'] }
end

# Say thanks to Riddell for this.
if params[:server_name] == 'build.neon.kde.org'
  redirect 'build.neon.kde.org.uk' do
    server_name 'build.neon.kde.org.uk'
    server_alias 'neon.pangea.pub'
    new_server_name 'build.neon.kde.org'
    server_port 80
    docroot '/var/www/images'
  end
end
