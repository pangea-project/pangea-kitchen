property :domains, Array
property :email, String
property :redirect, kind_of: [TrueClass, FalseClass], default: true

action :create do
  include_recipe 'apache2::default'
  include_recipe 'apache2::mod_ssl'
  include_recipe 'certbot::default'
  execute "certbot-apache-#{domains.join('_')}" do
    args = %w[--apache --non-interactive --agree-tos --no-eff-email]
    args << '--email' << email
    args << '--redirect' if redirect
    args << '--dyr-run' if node.name.include?('vagrant')
    args << domains.map { |k| "-d #{k}" }.join(' ')
    command "certbot #{args.join(' ')}"
  end
end
