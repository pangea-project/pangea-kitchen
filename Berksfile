site :opscode

# From git exclusively
cookbook 'apt-cacher-ng',
         git: 'https://github.com/markolson/chef-apt-cacher-ng.git'
cookbook 'chef-unattended-upgrades',
         git: 'https://github.com/firstbanco/chef-unattended-upgrades'
## Broken released version with recent Chefs
##  https://github.com/sethvargo-cookbooks/swap/issues/22
cookbook 'swap', git: 'https://github.com/sethvargo-cookbooks/swap.git'

# From supermarket
cookbook 'aptly'
## https://github.com/svanzoest-cookbooks/apache2/commit/c8c2410084bcb12dbffe5f0aa8a0ebd2668ae4e1
## we need 3.1 compat
cookbook 'apache2', '~> 3.1'
cookbook 'bsw_gpg', '~> 0.2.3'
cookbook 'compat_resource'
cookbook 'docker'
cookbook 'fail2ban'
cookbook 'htop'
cookbook 'git'
cookbook 'java'
cookbook 'jenkins'
cookbook 'kernel_module'
cookbook 'openssh'
cookbook 'ruby_build', '~> 0.8'
cookbook 'rvm', '~> 0.9.4' # v1 changes the entire node format around
cookbook 'swap_tuning'
cookbook 'system', '~> 0.10.1'
cookbook 'user'

## For site cookbooks
cookbook 'sysctl', '~> 0.7.0'