#
# Cookbook Name:: jenkins-kci
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'jenkins-master'
# include_recipe 'rvm::user'

jenkins_private_key_credentials 'kubuntu-ci-guest' do
  id '005d8204-e7c1-413f-b3f8-5cf5cef59de4'
  description ''
  private_key KeyBag.load(id)
end

jenkins_private_key_credentials 'jenkins' do
  id '7cc76b31-0f2b-44ea-b900-0667ff43dcbf'
  description 'github'
  private_key KeyBag.load(id)
end

jenkins_private_key_credentials 'jenkins-slave' do
  id '76207382-72f4-437c-acc6-16257a9c683b'
  description 'slave'
  private_key KeyBag.load(id)
end
