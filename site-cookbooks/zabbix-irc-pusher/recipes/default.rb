#
# Cookbook Name:: zabbix-irc-pusher
# Recipe:: default
#
# Copyright 2016, Harald Sitter <sitter@kde.org>
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'ruby_build::default'

# additional build depends
package %w(libssl-dev libreadline-dev zlib1g-dev build-essential)

# remove any system rubies (bound to 14.04)
apt_package 'ruby' do
  package_name %w(libruby1.9.1 libruby2.0)
  action :purge
end

ruby_build_ruby '2.3.0' do
  prefix_path	'/usr'
  # Skip documentation, we don't need it.
  environment('CONFIGURE_OPTS' => '--disable-install-doc')
end

gem_package 'bundler'

deploy 'zabbix-irc-pusher' do
  repo 'git://github.com/blue-systems/zabbix-irc-pusher.git'
  user 'root'
  deploy_to '/var/lib/zabbix-irc-pusher'
  migrate false
  action :deploy

  before_migrate do
    execute 'bundle install' do
      command 'bundle install'
      cwd release_path
      user user
    end
  end

  # Chef wants to do shit symlinks by default. Fuck off I say to that!
  symlink_before_migrate.clear
end

link '/usr/lib/zabbix/alertscripts/push_to_irc.rb' do
  to '/var/lib/zabbix-irc-pusher/current/push_to_irc.rb'
end
