include_recipe 'aptly'

%w(frameworks plasma).each do |repo|
  aptly_repo repo do
    action :create
    comment "packages for #{repo}"
    component 'main'
  end
end
