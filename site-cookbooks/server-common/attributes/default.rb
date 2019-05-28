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
default[:openssh][:server][:revoked_keys] = [
  ## Rohan Garg <garg@kde.org>
  'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDAZWkRp7cRdMELEt+7OXwQVqvh9zB5uMLSPqHSnrYoHBgQkiZZfihfFX8mt/aSQuZVRmj3JfcmVLq666jX20kJ8CxyfQ4gs3OXgNcALZaHKufPz1nRewqB/r27xa46rXA9lSnAywkZN3KxvZGWy9jhzcCnakqesIUuWgnYwzOL5PjeIWpbIVAbz9eVc29wSn6QRiGQswJqpTiI8zCyvrv2M0tc2Ntnl6SVf4PeYcUkwW2pvtUatv3bRNfLYgUQ8E6zuUm4Tv2gNhev4UYcRaIWres/g3Ie5GQUh/T+YN5pnkL7e0mOviUQ57IH9LoCkmdAQg+xkXH4TKmaT/cTa85WS3O9ys6jmRoiaoKVyfFh0mrLWnxjZj4ubYGIajqB0cGaiqoqRciN6Qslf00Rm8CuHHzlNgh3oVB7hbFU/+ztWqYkIr0cyyozHKTF/j4jAapMI8RLk3Jy3HRi+q+epGwZjGsnVRNHiZYKDAcJhlBr6SsRJz/7uxjmGO8Wh9zjAdV/MdE2Z8xamhHgNrYlqfUT4TZl2bIb6JCrXy+Z7Pga9k+8ergHkF348Uy+ngluELG+DXKRjwsAWzRbfWc6OIM5g2fKP+NbiyGVu6lzoe6T9e6HIVrnbO4S/7Fpat4gkz3xC/rO4H3e/i7In2h4g+j+rAAeZsj0R7poIQKb6p1QPw== shadeslayer@saphira'
]

# Fail2Ban
default[:fail2ban][:services][:ssh][:maxretry] = '2'
default[:fail2ban][:services][:ssh][:backend] = 'systemd'
default[:fail2ban][:services][:ssh][:ignoreip] = '127.0.0.1/8'
default[:fail2ban][:services][:ssh][:bantime] = '3600'
