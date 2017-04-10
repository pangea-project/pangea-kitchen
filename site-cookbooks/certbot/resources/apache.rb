property :domains, Array
property :email, String

action :create do
  execute "certbot-apache-#{domains.join('_')}" do
    command 'certbot --apache --non-interactive --agree-tos' \
            " --no-eff-email --redirect --email #{email}" \
            " #{domains.map { |k| "-d #{k}" }.join(' ')}"
  end
end
