#
# Cookbook Name:: pangea-ruby
# Recipe:: user_home_gems
#
# Copyright 2017, Harald Sitter <sitter@kde.org>
#
# All rights reserved - Do Not Redistribute
#

# FIXME: on slaves it isn't!
user_name = node['pangea_ruby']['home_user']
user_group = user_name
user_home = node['pangea_ruby']['home_user_home']

profile = "#{user_home}/.profile"
file profile do
  owner user_name
  group user_group
  action :create_if_missing
end

bash_profile = "#{user_home}/.bash_profile"
file bash_profile do
  owner user_name
  group user_group
  action :create_if_missing
end

[profile, bash_profile].each do |file|
  ruby_block 'gem_user_confinement' do
    block do
      file = Chef::Util::FileEdit.new(file)
      file.insert_line_if_no_match(/^export GEM_HOME/, <<-EOF)
# GEM_CONFINE_STAMP
export GEM_HOME=$(ruby -r rubygems -e 'puts Gem.user_dir')
export GEM_PATH=$GEM_HOME:$HOME/.gems/bundler
export PATH=$GEM_HOME/bin:$PATH
EOF
      file.write_file
    end
  end
end
