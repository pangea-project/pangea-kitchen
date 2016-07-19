#
# Cookbook Name:: jenkins-slave
# Recipe:: ruby
#
# Copyright 2015, Harald Sitter <sitter@kde.org>
#
# All rights reserved - Do Not Redistribute

include_recipe 'ruby_build::default'

# additional build depends
package %w(libssl-dev libreadline-dev zlib1g-dev build-essential
           libgirepository1.0-dev libglib2.0-dev)

# remove any system rubies (bound to 14.04)
apt_package 'ruby' do
  package_name %w(libruby1.9.1 libruby2.0)
  action :purge
end

ruby_build_ruby '2.2.2' do
  prefix_path	'/usr/local'
  # Skip documentation, we don't need it.
  environment('CONFIGURE_OPTS' => '--disable-install-doc')
end
