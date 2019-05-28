# OpenSSH
default[:openssh][:server][:print_motd] = 'no'
default[:openssh][:server][:permit_root_login] = 'yes'
default[:openssh][:server][:password_authentication] = 'no'
default[:openssh][:server][:port] = '22'
# Explicitly only allow proto 2
default[:openssh][:server][:protocol] = '2'
# Paswword login is disabled as per above, but we still want pam to run session
# setup etc to get dbus sockets as necessary.
default[:openssh][:server][:use_p_a_m] = 'yes'
# enable verbose logging to both track who uses an account and enable fail2ban
# filtering over journald
default[:openssh][:server][:log_level] = 'VERBOSE'
# do not allow passwords for root login, just in case.
default[:openssh][:server][:permit_root_login] = 'prohibit-password'
# obviously not allowed...
default[:openssh][:server][:permit_empty_passwords] = 'no'
# don't allow incorrect permissions on files
default[:openssh][:server][:strict_modes] = 'yes'
# X11 is about as secure as a garden shed
default[:openssh][:server][:x11_forwarding] = 'no'
# legacy nonesense allowing user@host combos to login without auth.
default[:openssh][:server][:ignore_rhosts] = 'yes'
# List of keys to prevent from getting used *at all*. This cannot be overridden
# the keys are out right rejected. Used for former company admins.
default[:openssh][:server][:revoked_keys] = '/etc/ssh/revoked_keys'
