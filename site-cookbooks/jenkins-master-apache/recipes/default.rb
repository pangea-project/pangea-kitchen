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
  jenkinshome: '/var/lib/jenkins'
}

application_name = params[:server_name]

include_recipe 'apache2::default'
include_recipe 'apache2::mod_proxy'

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
  if ::File.exist?("#{node['apache']['dir']}/sites-enabled/#{application_name}.conf")
    notifies :reload, 'service[apache2]', :delayed
  end
end

site_enabled = params[:enable]
apache_site params[:name] do
  enable site_enabled
end

# Say thanks to Riddell for this.
if server_name == 'build.neon.kde.org'
  redirect 'build.neon.kde.org.uk' do
    server_name 'build.neon.kde.org.uk'
    server_alias 'neon.pangea.pub'
    new_server_name 'build.neon.kde.org'
    server_port 80
    docroot '/var/www/images'
  end
end
