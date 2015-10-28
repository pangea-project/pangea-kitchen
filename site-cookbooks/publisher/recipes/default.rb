include_recipe "apt"

apt_repository "aptly" do
  uri node['aptly']['uri']
  distribution node['aptly']['dist']
  components node['aptly']['components']
  keyserver node['aptly']['keyserver']
  key node['aptly']['key']
  action :add
end

package "aptly"
package "graphviz"

# Requires LWRP'ing so as to enable multiple publishing accounts
repos_setup 'dci' do
  action :setup
  repositories %w(frameworks plasma)
end

# Requires LWRP'ing so as to enable multiple publishing accounts
repos_setup 'kci' do
  action :setup
  repositories %w(frameworks plasma)
end
