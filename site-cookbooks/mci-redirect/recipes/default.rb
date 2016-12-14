#
# Cookbook Name:: mci-redirect
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

redirect 'mobile.neon.pangea.pub' do
  server_name 'mobile.neon.pangea.pub'
  new_server_name 'neon.plasma-mobile.org:8080'
  server_port 80
  docroot '/var/www/html'
end
