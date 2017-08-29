default['apache']['redirects'] = %w[archive.neon.kde.org.uk]
default['aptly']['address'] = 'archive.neon.kde.org'
default['aptly']['apiport'] = 9090
default['aptly']['S3PublishEndpoints'] = {}
default['aptly']['user'] = 'nci'
default['apache']['default_modules'] = %w[proxy_http]