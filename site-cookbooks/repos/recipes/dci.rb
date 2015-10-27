include_recipe 'aptly'

node.default['aptly']['user'] = 'dci'
node.default['aptly']['group'] = 'dci'
node.default['aptly']['rootdir'] = '/home/dci'
%w(frameworks plasma).each do |repo|
  aptly_repo repo do
    action :create
    comment "packages for #{repo}"
    component 'main'
    distribution 'unstable'
  end
end
