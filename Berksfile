source 'https://supermarket.chef.io'

# From git exclusively
cookbook 'apt-cacher-ng',
         git: 'https://github.com/markolson/chef-apt-cacher-ng.git'
cookbook 'chef-unattended-upgrades',
         git: 'https://github.com/firstbanco/chef-unattended-upgrades'
cookbook 'compat_resource',
         git: 'https://github.com/chef-boneyard/compat_resource'

# From supermarket
cookbook 'aptly'
## https://github.com/svanzoest-cookbooks/apache2/commit/c8c2410084bcb12dbffe5f0aa8a0ebd2668ae4e1
## we need 3.1 compat
cookbook 'apache2', '~> 3.1'
cookbook 'bsw_gpg', '~> 0.2.3'
# NB: newer versions may be incompatible with chef 18. be careful when bumping this
cookbook 'docker', '~> 10.3.0'
cookbook 'fail2ban'
cookbook 'filesystem', '~> 0.10.6'
cookbook 'htop'
cookbook 'git'
cookbook 'java'
cookbook 'jenkins'
cookbook 'kernel_module', '~> 1.0.1'
cookbook 'openssh'
cookbook 'resolvconf', '~> 0.4.0'
cookbook 'ruby_build', '~> 1.1.0'
cookbook 'rvm', '~> 0.9.4' # v1 changes the entire node format around
cookbook 'swap_tuning'
cookbook 'system', '~> 0.11'
cookbook 'systemd', '~> 3.2'
cookbook 'swap', '~> 2.0'
cookbook 'user'

## For site cookbooks
## TODO: we could programtically let berks handle site-cookboks like supermarket
## ones https://coderwall.com/p/j72egw/organise-your-site-cookbooks-with-berkshelf-and-this-trick
cookbook 'sysctl', '~> 0.8.0'
