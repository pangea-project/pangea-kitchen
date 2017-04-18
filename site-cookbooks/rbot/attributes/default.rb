#
# Cookbook Name:: rbot
# Attributes:: default
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

require 'securerandom'

default['rbot']['user_name'] = 'rbot'
default['rbot']['user_home'] = "/home/#{node['rbot']['user_name']}"

default[:rbot][:config]['auth.password'] = SecureRandom.hex
default[:rbot][:config]['core.address_prefix'] = ''
default[:rbot][:config]['core.reply_with_nick'] = false
default[:rbot][:config]['core.nick_postfix'] = ':'
default[:rbot][:config]['core.language'] = 'english'
default[:rbot][:config]['server.list'] = %w[irc://chat.freenode.net]
default[:rbot][:config]['irc.nick'] = node['rbot']['user_name']
default[:rbot][:config]['irc.user'] = node['rbot']['user_name']
default[:rbot][:config]['irc.join_channels'] = []
default[:rbot][:config]['core.db'] = 'tc'
