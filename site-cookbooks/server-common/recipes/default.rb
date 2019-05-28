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
  storage 'persistent'
  # Disable syslog. We know how awesome journald is and syslog can sod off.
  # Otherwise jenkins and stuff floods the syslog and syslog unlike journald
  # has no storage limit really.
  forward_to_syslog false
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

file '/etc/update-motd.d/51-cloudguest' do
  action :delete
end

ruby_block 'disable-canonical-news' do
  block do
    file = Chef::Util::FileEdit.new('/etc/default/motd-news')
    file.search_file_replace_line('ENABLED=0', 'ENABLED=1')
    file.write_file
  end
end

# Make sure tzdata is installed for timezone cookbook.
apt_update 'update_for_tzdata'
apt_package 'tzdata'
# Make sure all servers have gpg2, we use this for most signing activity.
apt_package 'gnupg2'
