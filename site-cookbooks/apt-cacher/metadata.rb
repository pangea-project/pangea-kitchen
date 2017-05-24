name             'apt-cacher'
maintainer       'Harald Sitter'
maintainer_email 'sitter@kde.org'
license          'GNU Public License 3.0'
description      'Installs/Configures apt-cacher'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

chef_version '>= 13'
depends 'apache2'
depends 'apt'
depends 'certbot'
