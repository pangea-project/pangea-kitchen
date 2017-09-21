#!/bin/sh

set -ex

./ruby_version_check.rb && exit 0
echo 'No suitable ruby found, going to build a new one....'

# Install chef (+ knife + chef-client)
wget https://omnitruck.chef.io/install.sh
chmod +x install.sh
./install.sh -v 13

export NO_CUPBOARD=1 # Disable cupboard use (requires manual unlocking)

# Instead of berksing this, use knife to download the single dependency. Faster.
knife supermarket install ruby_build

chef-client --local-mode --enable-reporting  -o 'pangea-ruby::install'
