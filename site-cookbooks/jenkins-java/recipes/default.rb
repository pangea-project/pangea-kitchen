#
# Cookbook Name:: jenkins-java
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute

to_purge = []
to_install = []

if Chef::VersionConstraint.new('= 24.04').include?(node['platform_version'])
  # Default on 24.04 is openjdk21, but jenkins LTS wants openjdk11 or it
  # won't even start.
  #to_purge = %w[default-jre-headless]
  to_install = %w[default-jre-headless openjdk-17-jre-headless openjdk-11-jre-headless]
else
  to_install = %w[default-jre-headless]
end

package 'jenkins-java purge' do
  package_name to_purge
  action :purge
end

package 'jenkins-java install' do
  package_name to_install
  action :install
end
