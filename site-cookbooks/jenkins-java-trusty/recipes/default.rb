#
# Cookbook Name:: jenkins-java-trusty
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute

package 'openjdk-6-jre-headless openjdk-6-jre-lib' do
  action :purge  
end

package 'default-jre-headless openjdk-7-jre-headless' do
  action :install
end
