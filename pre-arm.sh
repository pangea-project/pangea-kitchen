#!/bin/sh

set -ex

apt-get install -y git
apt-get build-dep -y ruby2.0

cd /tmp
git clone https://github.com/sstephenson/ruby-build.git
cd ruby-build/
./install.sh

cd /
ruby-build 2.2.2 /usr/local/
