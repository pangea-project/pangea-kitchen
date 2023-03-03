#
# Cookbook Name:: pangea-ruby
# Recipe:: install
#
# Copyright 2017-2019, Harald Sitter <sitter@kde.org>
#
# All rights reserved - Do Not Redistribute
#

# additional build depends (these are required by the tooling's gems!)
package %w[libssl-dev libreadline-dev zlib1g-dev build-essential
           libgirepository1.0-dev libglib2.0-dev]

package %w[ruby ruby-dev]

file '/etc/gemrc' do
  content 'gem: --no-document'
  action :create_if_missing
end
