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
default[:openssh][:revoked_keys] = [
  ## Rohan Garg <garg@kde.org>
  'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDAZWkRp7cRdMELEt+7OXwQVqvh9zB5uMLSPqHSnrYoHBgQkiZZfihfFX8mt/aSQuZVRmj3JfcmVLq666jX20kJ8CxyfQ4gs3OXgNcALZaHKufPz1nRewqB/r27xa46rXA9lSnAywkZN3KxvZGWy9jhzcCnakqesIUuWgnYwzOL5PjeIWpbIVAbz9eVc29wSn6QRiGQswJqpTiI8zCyvrv2M0tc2Ntnl6SVf4PeYcUkwW2pvtUatv3bRNfLYgUQ8E6zuUm4Tv2gNhev4UYcRaIWres/g3Ie5GQUh/T+YN5pnkL7e0mOviUQ57IH9LoCkmdAQg+xkXH4TKmaT/cTa85WS3O9ys6jmRoiaoKVyfFh0mrLWnxjZj4ubYGIajqB0cGaiqoqRciN6Qslf00Rm8CuHHzlNgh3oVB7hbFU/+ztWqYkIr0cyyozHKTF/j4jAapMI8RLk3Jy3HRi+q+epGwZjGsnVRNHiZYKDAcJhlBr6SsRJz/7uxjmGO8Wh9zjAdV/MdE2Z8xamhHgNrYlqfUT4TZl2bIb6JCrXy+Z7Pga9k+8ergHkF348Uy+ngluELG+DXKRjwsAWzRbfWc6OIM5g2fKP+NbiyGVu6lzoe6T9e6HIVrnbO4S/7Fpat4gkz3xC/rO4H3e/i7In2h4g+j+rAAeZsj0R7poIQKb6p1QPw== shadeslayer@saphira',
  ## Old Debian CI key
  'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDgWtfEVwpqGHHO0JJ3d45wVnobPgexqmRslxbwYj6AuheLxwVdWtZapz+en4+Op9ZS6D70VXW0OmJG7xHaMAq87ZjMcozpp/ez2tUyIpQ3G5Ge7gq/hbhCz+K98pun56ECdhYrQEE/o5jVmG1mfrPDvTGm85PYNrdUVL97PmnOT7aiE58Ljv1EbbSaf/BxjPXrNACZcwmE2WeUJ2jo0wR4KpNIidTfJ/TSy571aX3YO30q8WzuFsTUUt8XQQvKt6r3wGiK9OEGuKjn3OaN6RDxqd/9JvJs700biYx9zmoE8Qmx2cjO5hXREIhEKf1yxtNppXj8A+RAL4+qC7PLzjMV jenkins@rassilon',
  ## Old Mobile CI key
  'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCsObI0X6VxK1/rwxIW3NDhKnLKpJJAHHBVHg1Iu/vjJba4cYBtW7KLz/9oryUDPuAdr9SegnnrZU9UMfiEv45tPJJvuJaKo8KYP1h1RHWNQF+1L5hfIahJ4tGdbF+SwPubWQV+K0JdGOD5pTnOXvwkpPgUDWdvfH7deSqlHfm+mmmrrtE2Rh9RE9cGnd0/nGoKlOOTXEWieNPFjEi2TFnYipCxJPPSE0O75ezpvKt5z2TLxLC4fAq1UlbtmV52/LdCdF5x7cE/BcXKJovqcSJ5cmNNetUCbiZDNtjhvg+j16hQquxd63gmteAQZZtkRGv+C7mswTiOjIR76NKexQIF jenkins@taspar',
]

# Fail2Ban
default[:fail2ban][:services][:ssh][:maxretry] = '2'
default[:fail2ban][:services][:ssh][:backend] = 'systemd'
default[:fail2ban][:services][:ssh][:ignoreip] = '127.0.0.1/8'
default[:fail2ban][:services][:ssh][:bantime] = '3600' # 1 hour

# Fail2Ban - aggressive (also bans failed negotiation etc which can be a sign of vulnerability probing e.g.)
default[:fail2ban][:services][:ssh_aggressive][:enabled] = 'true'
default[:fail2ban][:services][:ssh_aggressive][:maxretry] = '5'
default[:fail2ban][:services][:ssh_aggressive][:backend] = 'systemd'
default[:fail2ban][:services][:ssh_aggressive][:ignoreip] = '127.0.0.1/8'
default[:fail2ban][:services][:ssh_aggressive][:bantime] = '900' # 15 minutes
default[:fail2ban][:services][:ssh_aggressive][:filter] = 'sshd[mode=aggressive]'
default[:fail2ban][:services][:ssh_aggressive][:port] = 'ssh'
