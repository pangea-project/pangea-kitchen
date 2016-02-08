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
    'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8pDjCY6/xcZ86XYxglQMD9l/wE5neLjkuxXOOp0gumANFhl/X5yiCYQ94qyCnqFoUyhWJUFemTEJ0gBA5q2bjiy/+6yIgVgcDTh93cU+oCDXBuQZOdjGj8H0nKokk3VJxN+z0rM5IlUhJFE/xk4vsWgAag2ZZQtZu+powQLM80jMMTLQSsPjTi29wfsCYQPbBngiqbl/l0EQC1tTEAgWYU3n3Hm0F2nnUn/3wIRe5bN06TEpog+wL9Ap1WB4gak0H4HZ2L1twaPvEhssLDaj/ZlthX4TK0aSN2yKjIkbLr17ZPIyH7GnRXFfvaQmgm9Rr3uWedoYGasV2RVXOIX+P jenkins@river',
    'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCiLBt3u8Ldo3/bwIYI3t4QZ8yW7lMdWLy92gOxk0er5Rb1baKvubFIfTRL18I4FCvYJyzchCGZhxFfCkO5FiKNhOlKWbPJRKgitj1y6t02Jlyw0Z+zQXKe1srpwwQa2iN1LuTINcRoun/+Ouq52uQeRaye9zV3ikT+53/GcsfJTgxkJN2IOpIaLdEA3epuqnStpXdGYvAjycUngbVJASHWXsZUCPtZK6acxoxHvFPdroEVs+rB3HdWFUoaFECRJ8LQo21p7qlFIeC03scUmYs2cDaBne8h0NhA9q/0o+HQqaf2zam8fJiMqKo3eTYUt6jRStzxT+tpg3zyDlKsipL/ jenkins@drax'
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

ruby_block 'chown jenkins dirs' do
  block do
    %w(/var/lib/jenkins /var/cache/jenkins /var/lib/jenkins-slave).each do |dir|
      stamp = "#{dir}/chef_jenkins-master-chown.stamp"
      next unless File.exist?(dir)
      next if File.exist?(stamp)
      paths = Dir["#{dir}/**/**"] + [dir]
      paths.select! { |pt| !pt.include?('workspace') || pt.include?('cache') }
      FileUtils.chown('jenkins-slave', 'jenkins-slave', paths)
      FileUtils.touch(stamp)
      FileUtils.chown(100_000, 120, stamp)
    end
  end
end
