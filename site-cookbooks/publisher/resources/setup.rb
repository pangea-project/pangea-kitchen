property :uid, String, name_property: true
property :repositories, Array, default: []

action :setup do
  user_account uid do
    ssh_keys  [
      'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDgWtfEVwpqGHHO0JJ3d45wVnobPgexqmRslxbwYj6AuheLxwVdWtZapz+en4+Op9ZS6D70VXW0OmJG7xHaMAq87ZjMcozpp/ez2tUyIpQ3G5Ge7gq/hbhCz+K98pun56ECdhYrQEE/o5jVmG1mfrPDvTGm85PYNrdUVL97PmnOT7aiE58Ljv1EbbSaf/BxjPXrNACZcwmE2WeUJ2jo0wR4KpNIidTfJ/TSy571aX3YO30q8WzuFsTUUt8XQQvKt6r3wGiK9OEGuKjn3OaN6RDxqd/9JvJs700biYx9zmoE8Qmx2cjO5hXREIhEKf1yxtNppXj8A+RAL4+qC7PLzjMV jenkins@rassilon',
      'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8pDjCY6/xcZ86XYxglQMD9l/wE5neLjkuxXOOp0gumANFhl/X5yiCYQ94qyCnqFoUyhWJUFemTEJ0gBA5q2bjiy/+6yIgVgcDTh93cU+oCDXBuQZOdjGj8H0nKokk3VJxN+z0rM5IlUhJFE/xk4vsWgAag2ZZQtZu+powQLM80jMMTLQSsPjTi29wfsCYQPbBngiqbl/l0EQC1tTEAgWYU3n3Hm0F2nnUn/3wIRe5bN06TEpog+wL9Ap1WB4gak0H4HZ2L1twaPvEhssLDaj/ZlthX4TK0aSN2yKjIkbLr17ZPIyH7GnRXFfvaQmgm9Rr3uWedoYGasV2RVXOIX+P jenkins@river'
    ]
    ssh_keygen false
    create_group true
  end

  node.default['aptly']['rootdir'] = node['etc']['passwd'][uid]['dir']
  node.default['aptly']['group'] = uid
  node.default['aptly']['user'] = uid

  environment = {
    'USER' => uid,
    'HOME' => node.default['aptly']['rootdir']
  }

  template "#{node.default['aptly']['rootdir']}/.aptly.conf" do
    source 'aptly.conf.erb'
    owner uid
    group uid
    variables({
      :rootdir => "#{node.default['aptly']['rootdir']}/aptly",
      :downloadconcurrency => node['aptly']['downloadconcurrency'],
      :architectures => node['aptly']['architectures'],
      :dependencyfollowsuggests => node['aptly']['dependencyfollowsuggests'],
      :dependencyfollowrecommends => node['aptly']['dependencyfollowrecommends'],
      :dependencyfollowallvariants => node['aptly']['dependencyfollowallvariants'],
      :dependencyfollowsource => node['aptly']['dependencyfollowsource'],
      :gpgdisablesign => node['aptly']['gpgdisablesign'],
      :gpgdisableverify => node['aptly']['gpgdisableverify'],
      :downloadsourcepackages => node['aptly']['downloadsourcepackages'],
      :ppadistributorid => node['aptly']['ppadistributorid'],
      :ppacodename => node['aptly']['ppacodename']
    })
  end

  repositories.each do |repo|
    aptly_repo repo do
      action :create
      comment "Apt repository for #{repo}"
      component 'main'
    end
  end
end
