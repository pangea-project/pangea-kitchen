#
# Cookbook Name:: repo-mci
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

# Divert the databag for reprepro. It does not support multiple bags for
# multiple repos so we need to simulate it by switching bag lookup around.
data_bag_path = Chef::Config[:data_bag_path].dup
Chef::Config[:data_bag_path] = "#{File.dirname(File.dirname(File.realpath(__FILE__)))}/data_bags"
include_recipe 'reprepro'
Chef::Config[:data_bag_path] = data_bag_path

user_account 'publisher' do
  action :create
  home node['reprepro']['repo_dir']
  ssh_keys ['ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8pDjCY6/xcZ86XYxglQMD9l/wE5neLjkuxXOOp0gumANFhl/X5yiCYQ94qyCnqFoUyhWJUFemTEJ0gBA5q2bjiy/+6yIgVgcDTh93cU+oCDXBuQZOdjGj8H0nKokk3VJxN+z0rM5IlUhJFE/xk4vsWgAag2ZZQtZu+powQLM80jMMTLQSsPjTi29wfsCYQPbBngiqbl/l0EQC1tTEAgWYU3n3Hm0F2nnUn/3wIRe5bN06TEpog+wL9Ap1WB4gak0H4HZ2L1twaPvEhssLDaj/ZlthX4TK0aSN2yKjIkbLr17ZPIyH7GnRXFfvaQmgm9Rr3uWedoYGasV2RVXOIX+P jenkins@river']
  ssh_keygen false
end

group 'www-data' do
  action :modify
  append true
  members %w(publisher)
end

# Chef has no builtin recursive handling, force a chown via ruby glob match.
# NOTE: this does not match hidden directories,so .ssh is unchanged.
# https://tickets.opscode.com/browse/CHEF-690
Dir["#{node['reprepro']['repo_dir']}/**/**"].each do |path|
  file path do
    owner 'publisher'
    group 'www-data'
  end if File.file?(path)
  directory path do
    owner 'publisher'
    group 'www-data'
  end if File.directory?(path)
end
