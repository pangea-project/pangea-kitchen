#!/usr/bin/env ruby

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
      switches.each do |switch|
        short = switch.short
        long = switch.long
        short_present = short.any? { |s| default_argv.include?(s) }
        long_present = long.any? { |l| default_argv.include?(l) }
        unless short_present || long_present
          missing_expected
          @missing_expected << long ? long : short
        end
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

NAME_FILTERS = [' on veth', 'devicemapper/mnt', 'usage /var/lib/schroot/']

zbx = ZabbixApi.connect(
  url: "#{options.zabbix}/api_jsonrpc.php",
  user: options.username,
  password: options.password,
  debug: false
)

zbx.hosts.all.each do |host, hostid|
  puts "#{host} #{hostid}"
  graphids = zbx.graphs.get_ids_by_host(host: host)
  graphids.reject! do |graphid|
    graph = OpenStruct.new(zbx.graphs.dump_by_id(graphid: graphid)[0])
    NAME_FILTERS.any? { |f| graph.name.include?(f) }
  end
  screen = zbx.screens.get_id(name: host)

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

  id = zbx.screens.get_or_create_for_host(screen_name: host,
                                          graphids: graphids,
                                          vsize: vsize,
                                          hsize: hsize,
                                          width: 500,
                                          height: 100)
  puts "Created screen for #{host} with id #{id}"
end
