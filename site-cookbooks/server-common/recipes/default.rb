#
# Cookbook Name:: server-common
# Recipe:: default
#
# Copyright 2016, Harald Sitter <sitter@kde.org>
#
# All rights reserved - Do Not Redistribute
#

# Disable Translation-$lang apt archive fetching.
# We don't care and they only needlessly slow down apt update.
file '/etc/apt/apt.conf.d/99translations' do
  content 'Acquire::Languages "none";'
end
