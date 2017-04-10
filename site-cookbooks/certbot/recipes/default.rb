#
# Cookbook Name:: certbot
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

apt_repository 'certbot' do
  uri 'http://ppa.launchpad.net/certbot/certbot/ubuntu'
  distribution node['lsb']['codename']
  components ['main']
  keyserver 'keyserver.ubuntu.com'
  key '7BF576066ADA65728FC7E70A8C47BE8E75BCA694'
end

package 'python-certbot-apache'
