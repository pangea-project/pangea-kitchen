#!/bin/sh

set -ex

scp bootstrap-ruby.sh $1:/tmp/
ssh $1 sh /tmp/bootstrap-ruby.sh
