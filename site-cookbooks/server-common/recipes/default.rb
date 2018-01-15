#
# Cookbook Name:: server-common
# Recipe:: default
#
# Copyright 2016-2017, Harald Sitter <sitter@kde.org>
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

systemd_journald 'enable-peristence' do
  storage 'persistent'
  notifies :restart, 'service[systemd-journald-enable-peristence]', :delayed
  only_if do
    [node.fetch('platform'), node.fetch('platform_version')] != %w(ubuntu 14.04)
  end
end

# Make sure tzdata is installed for timezone cookbook.
apt_update 'update_for_tzdata'
apt_package 'tzdata'
