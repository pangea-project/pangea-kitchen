#
# Cookbook Name:: nameserver
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

package 'bind9'

service 'bind9' do
  action %i[enable start]
end

%w[named.conf.options named.conf.local db.10.135 db.pangea.pub].each do |file|
  template "/etc/bind/#{file}" do
    source file
    owner 'root'
    group 'bind' # NB: bind9 is run as user bind, we'll want it to read
    mode 0o640
    notifies :restart, 'service[bind9]'
  end
end
