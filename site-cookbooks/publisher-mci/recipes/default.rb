#
# Cookbook Name:: publisher-mci
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
publisher_setup 'mci' do
  action :setup
  sshkeys [
    'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8pDjCY6/xcZ86XYxglQMD9l/wE5neLjkuxXOOp0gumANFhl/X5yiCYQ94qyCnqFoUyhWJUFemTEJ0gBA5q2bjiy/+6yIgVgcDTh93cU+oCDXBuQZOdjGj8H0nKokk3VJxN+z0rM5IlUhJFE/xk4vsWgAag2ZZQtZu+powQLM80jMMTLQSsPjTi29wfsCYQPbBngiqbl/l0EQC1tTEAgWYU3n3Hm0F2nnUn/3wIRe5bN06TEpog+wL9Ap1WB4gak0H4HZ2L1twaPvEhssLDaj/ZlthX4TK0aSN2yKjIkbLr17ZPIyH7GnRXFfvaQmgm9Rr3uWedoYGasV2RVXOIX+P jenkins@river'
  ]
  apiport 9090
end

# GPG
include_recipe 'bsw_gpg::default'
bsw_gpg_load_key_from_string 'a string key' do
  key_contents KeyBag.load('mci.private.key')
  for_user 'mci'
end

# Apache
web_app 'mci_web_repo' do
  # server_name node['hostname']
  # server_aliases [node['fqdn'], 'neon.pangea.pub']
  server_name 'mobile.neon.pangea.pub'
  server_aliases ['mobile.kci.pangea.pub', 'mobile.neon.pangea.pub']
  server_port 80
  docroot '/home/mci/aptly/public/mci'
  directory_options %w(Indexes FollowSymLinks)
  allow_override 'All'
  cookbook 'apache2'
end
