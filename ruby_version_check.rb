#!/usr/bin/env ruby

require 'yaml'

target = YAML.load_file('ruby_version.yaml')
constraint = ">= #{target}"
if Gem::Dependency.new('', constraint).match?('', RUBY_VERSION)
  puts "Ruby version looks good enough (got #{RUBY_VERSION}, wanted #{target})."
  exit 0
end
warn "Ruby version not sufficient (got #{RUBY_VERSION}, wanted #{target})!"
exit 1
