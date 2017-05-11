cookbook_path    ["cookbooks", "site-cookbooks"]
node_path        "nodes"
role_path        "roles"
environment_path "environments"
data_bag_path    "data_bags"
#encrypted_data_bag_secret "data_bag_key"

cookbook_license 'gplv3'
cookbook_copyright ENV['DEBFULLNAME'] if ENV.include?('DEBFULLNAME')
cookbook_email ENV['DEBEMAIL'] if ENV.include?('DEBEMAIL')

if chefdk.generator # Chef 13 fully ditches knife for chef-dk.
  chefdk.generator.license = 'gplv3'
  chefdk.generator.copyright_holder = ENV['DEBFULLNAME'] if ENV.include?('DEBFULLNAME')
  chefdk.generator.email = ENV['DEBEMAIL'] if ENV.include?('DEBEMAIL')
end

# This is our default chef version. This only gets increased after testing!
knife[:bootstrap_version] = '13'
# Librarian compatibility.
knife[:berkshelf_path] = 'cookbooks'

def submod
  `git config --local --get include.path`
  unless $?.success?
    system('git submodule init') || raise
    system('git submodule update --remote') || raise
    system('git config --local include.path ../.gitconfig') || raise
    system('git fetch --verbose') || raise
  end
  system('git submodule update --remote --recursive') || raise
  cupboard_dir = "#{__dir__}/../data_bags/cupboard"
  puts 'Calling git secret reveal!'
  system('./bin/git-secret reveal -f', chdir: cupboard_dir) || raise
end
submod
