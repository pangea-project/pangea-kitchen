name             'publisher'
maintainer       'YOUR_COMPANY_NAME'
maintainer_email 'YOUR_EMAIL'
license          'All rights reserved'
description      'Installs/Configures repos'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends 'apt'
depends 'aptly'
depends 'compat_resource'
depends 'user'
depends 'bsw_gpg', '~> 0.2.3'
