#
# Cookbook Name:: pangea-ruby
# Recipe:: install
#
# Copyright 2017-2019, Harald Sitter <sitter@kde.org>
#
# All rights reserved - Do Not Redistribute
#

package %w[ruby ruby-dev]

file '/etc/gemrc' do
  content 'gem: --no-document'
  action :create_if_missing
end

# With ruby 2.4 string freezing is more strict. Update rubygems to prevent
# issues inside gem itself.
execute 'gem update --system'
