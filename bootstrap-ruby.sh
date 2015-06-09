#!/bin/sh

set -ex

apt-get update
apt-get install -y git
apt-get install -y ruby-dev build-essential wget ssl-cert rsync
apt-get purge -y ruby-dev

cd /tmp
rm -rf ruby-build
git clone https://github.com/sstephenson/ruby-build.git
cd ruby-build/
./install.sh

cd /
ruby-build 2.2.2 /usr/local/
