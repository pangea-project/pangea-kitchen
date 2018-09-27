property :user, String, name_property: true
property :repositories, Array, default: []
property :sshkeys, Array, default: []
# Setting this sets an explicit ListenStream for systemd.
# This overrides apiport. Passing a relative path.
property :listen_stream, [String, nil], default: nil
# Setting this means the listen_stream is treated as a socket path. If the path
# is relative it'll be absolutified against the user home directory.
# e.g. 'aptly.s' becomes '/home/user/aptly.s' as ListenStream in systemd.
property :listen_socket, [true, false], default: false

action :setup do
  node.default['aptly']['group'] = new_resource.user
  node.default['aptly']['user'] = new_resource.user

  # FIXME: Because I couldn't figure out how to achieve this via
  #        lazy variables.
  node.default['aptly']['rootdir'] = "/home/#{new_resource.user}"
  rootdir = node['aptly']['rootdir']

  # NB: be very careful with assignment of the same var. Because of how chef
  # works consturcts of the type `foo = if foo; x; else y; end` will always fall
  # into the else branch because foo is effectively not defined as it is
  # currently being assigned. So assignments of properties must always be
  # trivial!
  listen_stream = new_resource.listen_stream
  if new_resource.listen_socket
    # Absolutify. This only changes the value iff it isn't
    # absolute yet.
    x = ::File.absolute_path(listen_stream, rootdir)
    listen_stream = x
  end

  systemd_dir = "#{rootdir}/.config/systemd/user"
  # Force assign this to another var so we can easily access it in lazy scopes.
  # This is somewhat odd and I do not know why it is this way but inside
  # lazy scopes we don't always necessarily have access to the properties.
  # Giving the property a local scope makes it work as expected though. It's
  # somewhat odd and I actually suspect it has to do with how properties are
  # actually implemented inside ruby.
  username = new_resource.user

  ohai 'reload_passwd' do
    action :nothing
    plugin 'etc'
  end

  user_account new_resource.user do
    ssh_keygen false
    ssh_keys new_resource.sshkeys
    create_group true
    home node['aptly']['rootdir']
    notifies :reload, 'ohai[reload_passwd]', :immediately
  end

  ["#{rootdir}/aptly", "#{rootdir}/aptly/public"].each do |dir|
    directory dir do
      owner new_resource.user
      group new_resource.user
      mode 0o755
      action :create
      recursive true
    end
  end

  # Recursive creation has incorrect ownership. Manually mkdir so user and owner
  # are correct.
  # directory recursive docs:
  #   Create or delete parent directories recursively. For the owner, group, and
  #   mode properties, the value of this attribute applies only to the leaf
  #   directory.
  bash 'creating systemd user dir' do
    code "mkdir -pv #{systemd_dir}"
    creates systemd_dir
    user new_resource.user
    group new_resource.user
  end

  template "#{node['aptly']['rootdir']}/.aptly.conf" do
    source 'aptly.conf.erb'
    cookbook 'publisher'
    owner new_resource.user
    group new_resource.user
    variables(
      rootdir: "#{node['aptly']['rootdir']}/aptly",
      downloadconcurrency: node['aptly']['downloadconcurrency'],
      architectures: node['aptly']['architectures'],
      dependencyfollowsuggests: node['aptly']['dependencyfollowsuggests'],
      dependencyfollowrecommends: node['aptly']['dependencyfollowrecommends'],
      dependencyfollowallvariants: node['aptly']['dependencyfollowallvariants'],
      dependencyfollowsource: node['aptly']['dependencyfollowsource'],
      gpgdisablesign: node['aptly']['gpgdisablesign'],
      gpgdisableverify: node['aptly']['gpgdisableverify'],
      downloadsourcepackages: node['aptly']['downloadsourcepackages'],
      ppadistributorid: node['aptly']['ppadistributorid'],
      ppacodename: node['aptly']['ppacodename'],
      s3publishendpoints: node['aptly']['S3PublishEndpoints']
    )
  end

  new_resource.repositories.each do |repo|
    aptly_repo repo do
      action :create
      comment "Apt repository for #{repo}"
      component 'main'
    end
  end

  # Set up new systemd services

  # for session management via logind
  package %w[libpam-systemd dbus-user-session systemd-container]

  # The dbus-user-session installs a bus socket activation, but we need to make
  # sure the user service is being started so systemd controls the socket.
  # This needs to happen with lingering enabled or everything goes to hell.
  service 'user@.service' do
    service_name lazy { "user@#{node.fetch('etc').fetch('passwd').fetch(username).fetch('uid')}.service" }
    not_if { ::File.exist?("/run/user/#{node.fetch('etc').fetch('passwd').fetch(username).fetch('uid')}/bus") }
    action :nothing
  end

  execute 'enable-linger' do
    command "loginctl enable-linger #{username}"
    notifies :start, 'service[user@.service]', :immediately
  end

  execute 'restart-logind' do
    command 'systemctl restart systemd-logind.service'
  end

  execute 'daemon-reload' do
    command 'systemctl daemon-reload'
  end

  execute 'daemon-reload-user' do
    command lazy {
      "machinectl shell --uid #{username} .host /bin/systemctl --user daemon-reload"
    }
    user user
    group user
    action :nothing
  end

  systemd_unit 'aptly.service' do
    user username
    action :nothing # We'll reload/restart based on changes.
  end

  systemd_unit 'aptly.socket' do
    user username
    # Before we can do anything with the socket we need to make sure the
    # service is stopped. Otherwise socket changes will get rejected by systemd.
    notifies :stop, 'systemd_unit[aptly.service]', :before
    action :nothing # We'll reload/restart based on changes.
  end

  execute 'daemon-reload' do
    command 'systemctl daemon-reload'
  end

  template "#{systemd_dir}/aptly.service" do
    source 'aptly.service.erb'
    cookbook 'publisher'
    owner new_resource.user
    group new_resource.user
    mode 0o644
    variables user: new_resource.user,
              group: new_resource.user,
              home: rootdir
    notifies :run, 'execute[daemon-reload-user]', :immediately
    # Stop only, the service is started by its socket.
    notifies :stop, 'systemd_unit[aptly.service]', :delayed
  end

  template "#{systemd_dir}/aptly.socket" do
    source 'aptly.socket.erb'
    cookbook 'publisher'
    owner new_resource.user
    group new_resource.user
    mode 0o644
    variables user: new_resource.user,
              group: new_resource.user,
              home: rootdir,
              listen_stream: listen_stream
    notifies :run, 'execute[daemon-reload-user]', :immediately
    notifies :restart, 'systemd_unit[aptly.socket]', :delayed
  end

  # This resource prviously created more services. Only the main aptly service
  # remains for practical reasons:

  # aptly_serve is fully deprecated. It serves data from inside aptly and is a
  # security hazard. A proper webserver should be used instead.

  # aptly_cleanup is not available in systemd because of how it interacts
  # with running aptly.service, its functionality needs to be otherwise
  # employed. There is also some upstream work being done on giving more cleanup
  # access via the API.
end
