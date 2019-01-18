property :domains, Array
property :email, String
property :webroot_path, String
property :redirect, kind_of: [TrueClass, FalseClass], default: true

action :create do
  include_recipe 'apache2::default'
  include_recipe 'apache2::mod_ssl'
  include_recipe 'certbot::default'
  execute "certbot-apache-#{new_resource.domains.join('_')}" do
    unless webroot_path
      raise 'need to authenticate via webroot https://community.letsencrypt.org/t/february-13-2019-end-of-life-for-all-tls-sni-01-validation-support/74209'
    end

    args = %w[--non-interactive --agree-tos --no-eff-email --force-renewal]
    args << '--installer' << 'apache'
    args << '--authenticator' << 'webroot'
    args << '--webroot-path' << webroot_path
    args << '--email' << new_resource.email
    args << '--redirect' if new_resource.redirect
    args << '--test-cert' if node.name.include?('vagrant')
    args << new_resource.domains.map { |k| "-d #{k}" }.join(' ')
    command "certbot #{args.join(' ')}"
  end
end
