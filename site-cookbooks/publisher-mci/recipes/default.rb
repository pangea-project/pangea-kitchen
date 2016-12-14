#
# Cookbook Name:: publisher-mci
# Recipe:: default
#
# Copyright 2015, Harald Sitter <sitter@kde.org>
#
# All rights reserved - Do Not Redistribute
#

if node['apache']['listen'] == ['*:80']
  node.default['apache']['listen'] = ['*:80', "*:8080"]
end

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
publisher_setup 'mci' do
  action :setup
  sshkeys []
  apiport 9090
end

directory "/home/mci/images" do
  owner 'mci'
  group 'mci'
  mode '0755'
  action :create
  recursive true
end

# GPG
# Doesn't work currently with gpg2, done manually for now
# see: https://github.com/wied03/cookbook-gpg/issues/5
#include_recipe 'bsw_gpg::default'
#bsw_gpg_load_key_from_string 'a string key' do
#  key_contents KeyBag.load('mci.private.key')
#  for_user 'mci'
#end

# Apache
web_app 'mci_web_repo' do
  server_name 'neon.plasma-mobile.org'
  server_port 8080
  docroot '/home/mci/aptly/public/mci'
  directory_options %w(Indexes FollowSymLinks)
  allow_override 'All'
  cookbook 'apache2'
end

web_app 'mci_images' do
  server_name 'neon.plasma-mobile.org'
  server_port 80
  docroot '/home/mci/images'
  directory_options %w(Indexes FollowSymLinks)
  allow_override 'All'
  cookbook 'apache2'
end
