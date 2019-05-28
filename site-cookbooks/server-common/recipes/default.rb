#
# Cookbook Name:: server-common
# Recipe:: default
#
# Copyright 2016-2018, Harald Sitter <sitter@kde.org>
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

# Global revocations of former admin keys.
file '/etc/ssh/revoked_keys' do
  content <<-EOF
# Generated by Chef via server-common cookbook; additions need to happen there
## Rohan Garg <garg@kde.org>
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDAZWkRp7cRdMELEt+7OXwQVqvh9zB5uMLSPqHSnrYoHBgQkiZZfihfFX8mt/aSQuZVRmj3JfcmVLq666jX20kJ8CxyfQ4gs3OXgNcALZaHKufPz1nRewqB/r27xa46rXA9lSnAywkZN3KxvZGWy9jhzcCnakqesIUuWgnYwzOL5PjeIWpbIVAbz9eVc29wSn6QRiGQswJqpTiI8zCyvrv2M0tc2Ntnl6SVf4PeYcUkwW2pvtUatv3bRNfLYgUQ8E6zuUm4Tv2gNhev4UYcRaIWres/g3Ie5GQUh/T+YN5pnkL7e0mOviUQ57IH9LoCkmdAQg+xkXH4TKmaT/cTa85WS3O9ys6jmRoiaoKVyfFh0mrLWnxjZj4ubYGIajqB0cGaiqoqRciN6Qslf00Rm8CuHHzlNgh3oVB7hbFU/+ztWqYkIr0cyyozHKTF/j4jAapMI8RLk3Jy3HRi+q+epGwZjGsnVRNHiZYKDAcJhlBr6SsRJz/7uxjmGO8Wh9zjAdV/MdE2Z8xamhHgNrYlqfUT4TZl2bIb6JCrXy+Z7Pga9k+8ergHkF348Uy+ngluELG+DXKRjwsAWzRbfWc6OIM5g2fKP+NbiyGVu6lzoe6T9e6HIVrnbO4S/7Fpat4gkz3xC/rO4H3e/i7In2h4g+j+rAAeZsj0R7poIQKb6p1QPw== shadeslayer@saphira
  EOF
  owner root
  group root
  mode 0o600
  action :create
end

# Make sure tzdata is installed for timezone cookbook.
apt_update 'update_for_tzdata'
apt_package 'tzdata'
# Make sure all servers have gpg2, we use this for most signing activity.
apt_package 'gnupg2'
