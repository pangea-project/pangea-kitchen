#!/bin/sh
#
# Copyright (C) 2017 Harald Sitter <sitter@kde.org>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) version 3, or any
# later version accepted by the membership of KDE e.V. (or its
# successor approved by the membership of KDE e.V.), which shall
# act as a proxy defined in Section 6 of version 3 of the license.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library.  If not, see <http://www.gnu.org/licenses/>.

# Exits:
# 0:    no change
# 1:    change
# else: error

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

exit 1
# The rationale behind exit 1 is that installing a new ruby means that part of
# the calling utils need to reload in order to actually run it. If they do
# not explicitly handle the exit status codes exit 1 will at least cause
# a teardown, next time the utils are run the version should be aligned then.
