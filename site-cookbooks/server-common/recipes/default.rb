#
# Cookbook Name:: server-common
# Recipe:: default
#
# Copyright 2016-2019, Harald Sitter <sitter@kde.org>
#
# All rights reserved - Do Not Redistribute
#

# Disable Translation-$lang apt archive fetching.
# We don't care and they only needlessly slow down apt update.
file '/etc/apt/apt.conf.d/99translations' do
  content 'Acquire::Languages "none";'
end

service 'systemd-journald-enable-peristence' do
  service_name 'systemd-journald'
  action :nothing
end

systemd_journald 'enable-peristence-without-syslog' do
  journal_storage 'persistent'
  # Disable syslog. We know how awesome journald is and syslog can sod off.
  # Otherwise jenkins and stuff floods the syslog and syslog unlike journald
  # has no storage limit really.
  journal_forward_to_syslog false
  notifies :restart, 'service[systemd-journald-enable-peristence]', :delayed
  only_if do
    [node.fetch('platform'), node.fetch('platform_version')] != %w(ubuntu 14.04)
  end
end

# Disable canonical news nonesense. Nobody gives a flying F.
package 'ubuntu-advantage-tools' do
  action :purge
end

file '/etc/update-motd.d/10-help-text' do
  action :delete
end

file '/etc/update-motd.d/50-landscape-sysinfo' do
  action :delete
end

file '/etc/update-motd.d/50-motd-news' do
  action :delete
end

file '/etc/update-motd.d/51-cloudguest' do
  action :delete
end

# Disable man-db auto updates. They needlessly slow down apt.
execute 'disable-man-db-auto-update' do
  command 'echo "man-db man-db/auto-update boolean false" | debconf-set-selections'
end
# More modern variant
file '/var/lib/man-db/auto-update' do
  action :delete
end

# Clean up some crap we most definitely never need.
package 'crap purge' do
  package_name %w[plymouth packagekit accountsservice rsyslog policykit-1]
  action :purge
end

# Make sure tzdata is installed for timezone cookbook.
apt_update 'update_for_tzdata'
# - Make sure all servers have gpg2, we use this for most signing activity.
# - update-notifier-common contains handy motd extensions
# - systemd-container contains machinectl which is much better than sudo
apt_package %w[tzdata gnupg2 update-notifier-common systemd-container]

# For some unknown reason chef 15.17.4 ships with ruby 2.6.7 that includes ruby-shadow
# but chef-workstation 23.4.1032 ships ruby 3.1.2 but does not include ruby-shadow which
# make it a complete shit show.  So chef_gem it in early.
# See: https://github.com/chef/chef-workstation/issues/2141
chef_gem 'ruby-shadow' do
  action :install
  ignore_failure true
end
