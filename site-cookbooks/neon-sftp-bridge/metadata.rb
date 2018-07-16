name             'neon-sftp-bridge'
maintainer       'Harald Sitter'
maintainer_email 'sitter@kde.org'
license          'All rights reserved'
description      'Installs/Configures neon-sftp-bridge'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

chef_version '>= 13'
depends 'apache2'
depends 'certbot'
