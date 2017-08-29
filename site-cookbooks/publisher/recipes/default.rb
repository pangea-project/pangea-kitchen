#
# Cookbook Name:: publisher
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
user = node['aptly']['user']
publisher_setup user do
  action :setup
  sshkeys []
  apiport node['aptly']['apiport']
end

# GPG
include_recipe 'bsw_gpg::default'

# user = node['aptly']['user']
# bsw_gpg_load_key_from_string 'a string key' do
#   key_contents KeyBag.load(user)
#   for_user user
# end

# Apache
address = node['aptly']['address']
doc_root = "/home/#{user}/aptly/public"
web_app address do
  server_name address
  server_port 80
  docroot doc_root
  directory_options %w(Indexes FollowSymLinks)
  allow_override 'All'
  apiport node['aptly']['apiport']
end

redirects = node['apache']['redirects']
redirects.each do |redirect|
  redirect redirect do
    server_name redirect
    new_server_name address
    server_port 80
    docroot doc_root
  end
end