#
# Cookbook Name:: jenkins-java
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute

to_purge = %w(openjdk-6-jre-headless openjdk-6-jre-lib)
to_install = %w(default-jre-headless openjdk-8-jre-headless)

package 'jenkins-java purge' do
  package_name to_purge
  action :purge
end

package 'jenkins-java install' do
  package_name to_install
  action :install
end
