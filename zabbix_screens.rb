#!/usr/bin/env ruby
#
# Copyright (C) 2015 Harald Sitter <sitter@kde.org>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License or (at your option) version 3 or any later version
# accepted by the membership of KDE e.V. (or its successor approved
# by the membership of KDE e.V.), which shall act as a proxy
# defined in Section 14 of version 3 of the license.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'zabbixapi'
require 'optparse'
require 'ostruct'

options = OpenStruct.new
options.zabbix = 'http://46.101.162.153/zabbix'
options.username = nil
options.password = nil

class OptionParser
  def missing_expected
    @missing_expected ||= []
  end

  alias_method :super_make_switch, :make_switch
  # Decided whether an expected arg is present depending on whether it is in
  # default_argv. This is slightly naughty since it processes them out of order.
  # Alas, we don't usually parse >1 time and even if so we care about both
  # anyway.
  def make_switch(opts, block = nil)
    switches = super_make_switch(opts, block)

    if opts.delete('EXPECTED')
      switch = switches[0] # >0 are actually parsed versions
      short = switch.short
      long = switch.long
      short_present = short.any? { |s| default_argv.include?(s) }
      long_present = long.any? { |l| default_argv.include?(l) }
      unless short_present || long_present
        missing_expected
        @missing_expected << long[0] ? long[0] : short[0]
      end
    end

    switches
  end
end

parser = OptionParser.new do |opts|
  opts.banner = "Usage: #{opts.program_name} [options]"

  opts.separator ''
  opts.separator 'Options:'

  opts.on('-h', '--host HOST', "Zabbix host url (#{options.zabbix})") do |v|
    options.zabbix = v
  end

  opts.on('-u', '--username USERNAME', 'Zabbix user name',
          'EXPECTED') do |v|
    options.username = v
  end

  opts.on('-p', '--password PASSWORD', 'Zabbix user password',
          'EXPECTED') do |v|
    options.password = v
  end
end
parser.parse!

unless parser.missing_expected.empty?
  puts "Missing expected arguments: #{parser.missing_expected.join(', ')}\n\n"
  abort parser.help
end

NAME_FILTERS = [
  'traffic on docker',
  'traffic on veth',
  'devicemapper/mnt',
  'usage /var/lib/schroot/',
  'usage /var/lib/docker/devicemapper'
]

zbx = ZabbixApi.connect(
  url: "#{options.zabbix}/api_jsonrpc.php",
  user: options.username,
  password: options.password,
  debug: false
)

screen_names = []
zbx.hosts.all.each do |host, hostid|
  puts "#{host} #{hostid}"
  graphids = zbx.graphs.get_ids_by_host(host: host)
  graphids.reject! do |graphid|
    graph = OpenStruct.new(zbx.graphs.dump_by_id(graphid: graphid)[0])
    NAME_FILTERS.any? { |f| graph.name.include?(f) }
  end
  name = "#{host}.autoscreen"
  screen_names << name

  screen = zbx.screens.get_id(name: name)
  if screen
    screenitems = zbx.client.api_request(
      method: 'screen.get',
      params: {
        filter: {
          screenid: screen
        },
        selectScreenItems: 'extend',
        output: 'extend'
      }
    ).fetch(0).fetch('screenitems')

    new_graphids = graphids.dup
    old_graphids = screenitems.map { |item| item.fetch('resourceid') }

    if new_graphids == old_graphids
      puts "skipping #{host}; up-to-date already"
      next
    end

    puts "Deleting #{host}; to create new version"
    zbx.screens.delete(screen)
  end

  # Bug in Zabbix 2.2 when vsize is dividable by hsize. So vsize+1 when that is
  # the case.
  #   https://support.zabbix.com/browse/ZBX-7338
  hsize = 3
  vsize = graphids.size / hsize
  vsize += 1 if graphids.size % hsize

  id = zbx.screens.get_or_create_for_host(screen_name: name,
                                          graphids: graphids,
                                          vsize: vsize,
                                          hsize: hsize,
                                          width: 500,
                                          height: 100)
  puts "Created screen for #{host} with id #{id}"
end

dangling_screens = zbx.screens.all.reject do |name, _id|
  screen_names.include?(name) || !name.end_with?('.autoscreen')
end
dangling_screens.each do |name, id|
  puts "Deleting #{name}(#{id}) as its host appears to have disappeared."
  zbx.screens.delete(id)
end
