#
# Cookbook Name:: rbot
# Recipe:: default
#
# Copyright 2017, Harald Sitter
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

package %w[git ruby ruby-dev libtokyocabinet-dev tokyocabinet-bin zlib1g-dev
           libbz2-dev libgmp-dev build-essential]

user_name = node['rbot']['user_name']
group_name = user_name
user_home = node['rbot']['user_home']
# service_name = "rbot-#{user_name}"
rbot_dir = "#{user_home}/rbot"

user user_name do
  comment 'rbot User'
  home user_home
  manage_home true
end

git rbot_dir do
  repository 'https://github.com/ruby-rbot/rbot.git'
  depth 1
  user user_name
  group group_name
  action :sync
end

bash 'gem-install-bundler' do
  code 'gem install bundler'
end

bash 'bundle-update' do
  code "bundle update --jobs=#{`nproc`.chop}"
  cwd rbot_dir
  user user_name
  group group_name
end

directory "#{user_home}/.rbot" do
  owner user_name
  group group_name
  mode 0o700
end

git "#{user_home}/.rbot/netbotter-plugins" do
  repository 'https://github.com/blue-systems/netbotter-plugins.git'
  depth 1
  user user_name
  group group_name
  action :sync
end

warn 'We do not auto generate conf.yaml becuase of secret channel business -.-'

# # Chef uses internal derivates of hash and array which do not properly serialize
# # through YAML. To bypass this, force them into their base type.
# config = node['rbot']['config'].to_h
# config = config.map do |k, v|
#   v = v.to_a if v.is_a?(Array)
#   [k, v]
# end.to_h
#
# file "#{user_home}/.rbot/conf.yaml" do
#   content YAML.dump(config)
#   mode 0o600
#   user user_name
#   group group_name
# end

systemd_unit "rbot-#{user_name}.service" do
  content <<-EOF
[Unit]
Description=rbot

[Service]
ExecStartPre=/usr/local/bin/bundle install
ExecStart=/usr/local/bin/bundle exec #{user_home}/rbot/launch_here.rb
WorkingDirectory=#{user_home}/rbot
User=#{user_name}
Group=#{group_name}
RuntimeMaxSec=4hours
EOF
  triggers_reload
  action %i[create]
end

systemd_unit "rbot-#{user_name}.timer" do
  content <<-EOF
[Unit]
Description=rbot

[Timer]
OnCalendar=Tue 11:50:00

[Install]
WantedBy=timers.target
EOF
  triggers_reload
  action %i[create enable reload_or_restart]
end
