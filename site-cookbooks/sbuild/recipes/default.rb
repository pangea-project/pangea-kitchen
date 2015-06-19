#
# Cookbook Name:: sbuild
# Recipe:: default
#
# Copyright 2015, Rohan Garg
#
# All rights reserved - Do Not Redistribute
#

%w(sbuild ubuntu-dev-tools pbuilder).each do |pkg|
  package pkg
end

group 'sbuild' do
  action :modify
  append true
  members %w(jenkins-slave)
end

DEBIAN_RELEASES = %w(sid)

cookbook_file 'mk-sbuild.rc' do
  path '/root/.mk-sbuild.rc'
  action :create
end

DEBIAN_RELEASES.each do |release|
  execute "Building schroot for #{release}" do
    command "mk-sbuild --eatmydata #{release}"
    not_if { Dir["/var/lib/schroot/chroots/#{release}-*"].count > 0 }
    user 'root'
    group 'sbuild'
    environment ({ 'HOME' => '/root/' })
    action :run
  end
end

cookbook_file '15overlayworkspace' do
  path '/etc/schroot/setup.d/15overlayworkspace'
  action :create
  mode 0777
end
