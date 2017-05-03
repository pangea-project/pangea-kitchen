#!/usr/bin/env ruby

module DiskIDWriter
  def attach_storage(*)
    File.write("#{VBox.volume}.disk-id", VBox.medium_by_id(VBox.volume))
    super
  end

  def detach_storage(env)
    if ARGV.include?('destroy')
      warn '...noop'
    else
      super
    end
    # Disable detaching so the image gets deleted on destroy
  end
end

# VBox compatible uuid string parser. Eats uuid string and splits into 32bit
# integer array.
class RTUUID
  attr_reader :au32_s

  def initialize(string)
    # NB: VBox uses little endian for the first 3 ints but network (i.e. big)
    #     for the last int as documented in VBox' types.h
    #     As a consequence we'll have to do an endian flip of the string
    #     UUID so that our au32[3] == vbox' au32[3].
    hex = string.delete('-')
    # This is a tad convoluted.
    # Pack the hex chars into a binary blob and then unpack that blob as network
    # integers (big endian)
    ints = [hex].pack('h*').unpack('N*')
    # Then pack them again but this time flip the 4th integer to little endian.
    # NOTE: this doesn't actually do anything other than toggling the endian of
    #       the last integer.
    # For convenience do not unpack into one long hex string but a split array
    # of the 4 integers.
    @au32_s = ints.pack('NNNL<').unpack('h8h8h8h8')
  end
end

# VBox hacky module.
module VBox
  module_function

  def volume
    "#{__dir__}/.vagrant-volumes/do-volume-neon-jenkins.vdi"
  end

  def medium_by_id(_medium)
    # sda is vbox core
    # sdb is vbox fuu
    # sdb
    '/dev/sdc'
  end
end

if File.realpath(__FILE__) == File.absolute_path($PROGRAM_NAME)
  id = VBox.medium_by_id(VBox.volume)
  file = "#{VBox.volume}.disk-id"
  puts "Volume ID: #{id}"
  puts "  writing to #{file}"
  File.write(file, id)
end
