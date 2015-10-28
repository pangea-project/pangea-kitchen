property :uid, String, name_property: true
property :repositories, Array, default: []
property :sshkeys, Array, default: []

action :setup do
  # FIXME: Because I couldn't figure out how to achieve this via
  #        lazy variables.
  node.default['aptly']['rootdir'] = "/home/#{uid}"

  user_account uid do
    ssh_keygen false
    ssh_keys sshkeys
    create_group true
    home node.default['aptly']['rootdir']
  end

  ohai 'reload' do
    action :reload
    plugin 'etc'
  end

  node.default['aptly']['group'] = uid
  node.default['aptly']['user'] = uid

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

  environment = {
    'USER' => uid,
    'HOME' => node.default['aptly']['rootdir']
  }

  repositories.each do |repo|
    aptly_repo repo do
      action :create
      comment "Apt repository for #{repo}"
      component 'main'
    end
  end
end
