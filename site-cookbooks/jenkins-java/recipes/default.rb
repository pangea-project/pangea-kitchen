#
# Cookbook Name:: jenkins-java
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute

to_purge = []
to_install = []

if Chef::VersionConstraint.new('= 18.04').include?(node['platform_version']) ||
   Chef::VersionConstraint.new('= 20.04').include?(node['platform_version'])
  # Default on 18.04 is openjdk11, but jenkins LTS is wants openjdk8 or it
  # won't even start.
  to_purge = %w[default-jre-headless openjdk-11-jre-headless]
  to_install = %w[openjdk-8-jre-headless]
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
