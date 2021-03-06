name             'publisher'
maintainer       'Harald Sitter <sitter@kde.org>'
maintainer_email 'YOUR_EMAIL'
license          'All rights reserved'
description      'Installs/Configures publisher'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends 'apache2'
depends 'apt'
depends 'aptly'
depends 'bsw_gpg', '~> 0.2.3'
depends 'user'
