#
# Cookbook Name:: pangea-ruby
# Recipe:: install
#
# Copyright 2017, Harald Sitter <sitter@kde.org>
#
# All rights reserved - Do Not Redistribute
#

# Make sure we have the most recent ruby-build
node.default['ruby_build']['upgrade'] = 'sync'
include_recipe 'ruby_build::default'

# additional build depends
package %w[libssl-dev libreadline-dev zlib1g-dev build-essential
           libgirepository1.0-dev libglib2.0-dev]

# remove any system rubies (bound to 14.04)
apt_package 'ruby' do
  package_name %w[libruby1.9.1 libruby2.0]
  action :purge
end

# The target ruby version. The actual version is loaded from our yaml config.
# It's not an attribute because we want it visibly outside the tree and
# we don't want this overridden.
# NB: this is in files because otherwise chef-client --local-mode will not
#    provide it in the cache -.-
version_file =
  format('%s/cookbooks/pangea-ruby/files/default/ruby_version.yaml',
         Chef::Config[:file_cache_path])
target_version = YAML.load_file(version_file)

ruby_build_ruby target_version do
  prefix_path '/usr/local'
  # Skip documentation, we don't need it.
  environment('CONFIGURE_OPTS' => '--disable-install-doc')
  action %i[install reinstall]
  # The cookbook is very daft and does not even try to determine if the version
  # add up. So, override it. The resource is going to do a reinstall but we'll
  # only run it if the actively used ruby version is not the target version
  # we want.
  not_if { `ruby -v`.strip.include?("ruby #{target_version}") }
end

file '/usr/local/etc/gemrc' do
  content 'gem: --no-document'
  action :create_if_missing
end

# With ruby 2.4 string freezing is more strict. Update rubygems to prevent
# issues inside gem itself.
execute '/usr/local/bin/gem update --system'
