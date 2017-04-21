property :domains, Array
property :email, String
property :redirect, kind_of: [TrueClass, FalseClass], default: true

action :create do
  execute "certbot-apache-#{domains.join('_')}" do
    command 'certbot --apache --non-interactive --agree-tos' \
            " --no-eff-email --email #{email}" \
            " #{redirect ? '--redirect' : ''}" \
            " #{domains.map { |k| "-d #{k}" }.join(' ')}"
  end
end
