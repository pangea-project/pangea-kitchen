#
# Cookbook Name:: publisher-nci
# Recipe:: default
#
# Copyright 2015, Harald Sitter <sitter@kde.org>
#
# All rights reserved - Do Not Redistribute
#

## FIXME: codecopy
include_recipe 'apt'

apt_repository 'aptly' do
  uri node['aptly']['uri']
  distribution node['aptly']['dist']
  components node['aptly']['components']
  keyserver node['aptly']['keyserver']
  key node['aptly']['key']
  action :add
end

package 'aptly'
package 'graphviz'
## FIXME: codecopy

# Publisher User
publisher_setup 'nci' do
  action :setup
  sshkeys []
  apiport 9090
end

# GPG
include_recipe 'bsw_gpg::default'
bsw_gpg_load_key_from_string 'a string key' do
  key_contents KeyBag.load('nci.private.key')
  for_user 'nci'
end

# Apache
web_app 'archive.neon.kde.org' do
  server_name 'archive.neon.kde.org'
  server_port 80
  docroot '/home/nci/aptly/public'
  directory_options %w(Indexes FollowSymLinks)
  allow_override 'All'
  apiport 9090
end

redirect 'archive.neon.kde.org.uk' do
  server_name 'archive.neon.kde.org.uk'
  new_server_name 'archive.neon.kde.org'
  server_port 80
  docroot '/home/nci/aptly/public'
end
