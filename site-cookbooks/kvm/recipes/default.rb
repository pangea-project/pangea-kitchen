#
# Cookbook:: kvm
# Recipe:: default
#
# Copyright:: 2018,  Harald Sitter
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

# kvm
# cpu-checker: kvm-ok tool
# qemu package: makes sure kvm is accessible for qemu (adds kvm group etc.)
apt_package %w[kvm cpu-checker qemu-system-common]

ruby_block 'kvm-ok' do
  block do
    system('kvm-ok') || 'KVM not usable!'
  end
end

ohai 'reload_passwd' do
  action :nothing
  plugin 'etc'
end

group 'kvm' do
  append true
  members lazy {
    %w[jenkins-slave].select do |username|
      node['etc']['passwd'][username]
    end
  }
end
