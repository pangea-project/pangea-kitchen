#
# Cookbook Name:: jenkins-slave
# Recipe:: default
#
# Copyright 2015, Harald Sitter <sitter@kde.org>
#
# All rights reserved - Do Not Redistribute

slave_home = '/var/lib/jenkins-slave'

include_recipe 'user'
include_recipe 'openssh'

user_account 'jenkins-slave' do
  ssh_keys  [
    'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDgWtfEVwpqGHHO0JJ3d45wVnobPgexqmRslxbwYj6AuheLxwVdWtZapz+en4+Op9ZS6D70VXW0OmJG7xHaMAq87ZjMcozpp/ez2tUyIpQ3G5Ge7gq/hbhCz+K98pun56ECdhYrQEE/o5jVmG1mfrPDvTGm85PYNrdUVL97PmnOT7aiE58Ljv1EbbSaf/BxjPXrNACZcwmE2WeUJ2jo0wR4KpNIidTfJ/TSy571aX3YO30q8WzuFsTUUt8XQQvKt6r3wGiK9OEGuKjn3OaN6RDxqd/9JvJs700biYx9zmoE8Qmx2cjO5hXREIhEKf1yxtNppXj8A+RAL4+qC7PLzjMV jenkins@rassilon',
    'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8pDjCY6/xcZ86XYxglQMD9l/wE5neLjkuxXOOp0gumANFhl/X5yiCYQ94qyCnqFoUyhWJUFemTEJ0gBA5q2bjiy/+6yIgVgcDTh93cU+oCDXBuQZOdjGj8H0nKokk3VJxN+z0rM5IlUhJFE/xk4vsWgAag2ZZQtZu+powQLM80jMMTLQSsPjTi29wfsCYQPbBngiqbl/l0EQC1tTEAgWYU3n3Hm0F2nnUn/3wIRe5bN06TEpog+wL9Ap1WB4gak0H4HZ2L1twaPvEhssLDaj/ZlthX4TK0aSN2yKjIkbLr17ZPIyH7GnRXFfvaQmgm9Rr3uWedoYGasV2RVXOIX+P jenkins@river'
  ]
  home slave_home
  ssh_keygen false
  create_group false
  uid 100_000
end

group 'jenkins-slave' do
  action :create
  append true
  members %w(jenkins-slave)
  gid 120
end

group 'docker' do
  action :modify
  append true
  members %w(jenkins-slave)
end

%w(/var/lib/jenkins /var/cache/jenkins /var/lib/jenkins-slave).each do |dir|
  next unless File.exist?(dir)
  stamp = "#{dir}/chef_jenkins-master-chown.stamp"
  next if File.exist?(stamp)
  paths = Dir["#{dir}/**/**"] + [dir]
  paths.each do |path|
    # Do not mangle workspace permissions as they can be different due to
    # lack of subuid in docker.
    next if path.include?('workspace')
    file path do
      owner 'jenkins'
      group 'jenkins'
    end if File.file?(path)
    directory path do
      owner 'jenkins'
      group 'jenkins'
    end if File.directory?(path)
  end
  file stamp do
    content ''
    mode '0644'
    owner 'jenkins'
  end
end
