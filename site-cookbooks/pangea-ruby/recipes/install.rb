#
# Cookbook Name:: pangea-ruby
# Recipe:: install
#
# Copyright 2017, Harald Sitter <sitter@kde.org>
#
# All rights reserved - Do Not Redistribute
#

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
ruby_build_ruby YAML.load_file("#{__dir__}/ruby_version.yaml") do
  prefix_path '/usr/local'
  # Skip documentation, we don't need it.
  environment('CONFIGURE_OPTS' => '--disable-install-doc')
end

file '/usr/local/etc/gemrc' do
  content 'gem: --no-document'
  action :create_if_missing
end

# With ruby 2.4 string freezing is more strict. Update rubygems to prevent
# issues inside gem itself.
execute '/usr/local/bin/gem update --system'
