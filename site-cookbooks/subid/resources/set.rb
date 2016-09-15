#
# Cookbook Name:: subid
# Resource:: set
#
# Copyright 2016, Harald Sitter <sitter@kde.org>
#
# All rights reserved - Do Not Redistribute
#

property :username, String, required: true
property :uid, Fixnum, required: true
property :groupname, String, required: true
property :gid, Fixnum, required: true

default_action :default

action :default do
  ruby_block 'subuid-set' do
    block do
      values = { SubUID => [username, uid], SubGID => [groupname, gid] }
      values.each do |klass, array|
        klass.set(*array)
      end
    end
  end
end
