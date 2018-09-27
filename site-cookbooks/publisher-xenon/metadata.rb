name 'publisher-xenon'
maintainer 'Harald Sitter'
maintainer_email 'sitter@kde.org'
license 'GPL-3.0'
description 'Installs/Configures publisher-xenon'
long_description 'Installs/Configures publisher-xenon'
version '0.1.0'
chef_version '>= 12.14' if respond_to?(:chef_version)

# The `issues_url` points to the location where issues for this cookbook are
# tracked.  A `View Issues` link will be displayed on this cookbook's page when
# uploaded to a Supermarket.
#
# issues_url 'https://github.com/<insert_org_here>/publisher-xenon/issues'

# The `source_url` points to the development repository for this cookbook.  A
# `View Source` link will be displayed on this cookbook's page when uploaded to
# a Supermarket.
#
# source_url 'https://github.com/<insert_org_here>/publisher-xenon'

depends 'apache2'
depends 'apt'
depends 'publisher'
depends 'certbot'
