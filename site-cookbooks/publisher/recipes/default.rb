include_recipe 'apt'

apt_repository 'aptly' do
  uri node['aptly']['uri']
  distribution node['aptly']['dist']
  components node['aptly']['components']
  keyserver node['aptly']['keyserver']
  key node['aptly']['key']
  action :add
end

package 'aptly'
package 'graphviz'

# Requires LWRP'ing so as to enable multiple publishing accounts

publisher_setup 'dci' do
  action :setup
  sshkeys [
    'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDgWtfEVwpqGHHO0JJ3d45wVnobPgexqmRslxbwYj6AuheLxwVdWtZapz+en4+Op9ZS6D70VXW0OmJG7xHaMAq87ZjMcozpp/ez2tUyIpQ3G5Ge7gq/hbhCz+K98pun56ECdhYrQEE/o5jVmG1mfrPDvTGm85PYNrdUVL97PmnOT7aiE58Ljv1EbbSaf/BxjPXrNACZcwmE2WeUJ2jo0wR4KpNIidTfJ/TSy571aX3YO30q8WzuFsTUUt8XQQvKt6r3wGiK9OEGuKjn3OaN6RDxqd/9JvJs700biYx9zmoE8Qmx2cjO5hXREIhEKf1yxtNppXj8A+RAL4+qC7PLzjMV jenkins@rassilon',
    'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDAZWkRp7cRdMELEt+7OXwQVqvh9zB5uMLSPqHSnrYoHBgQkiZZfihfFX8mt/aSQuZVRmj3JfcmVLq666jX20kJ8CxyfQ4gs3OXgNcALZaHKufPz1nRewqB/r27xa46rXA9lSnAywkZN3KxvZGWy9jhzcCnakqesIUuWgnYwzOL5PjeIWpbIVAbz9eVc29wSn6QRiGQswJqpTiI8zCyvrv2M0tc2Ntnl6SVf4PeYcUkwW2pvtUatv3bRNfLYgUQ8E6zuUm4Tv2gNhev4UYcRaIWres/g3Ie5GQUh/T+YN5pnkL7e0mOviUQ57IH9LoCkmdAQg+xkXH4TKmaT/cTa85WS3O9ys6jmRoiaoKVyfFh0mrLWnxjZj4ubYGIajqB0cGaiqoqRciN6Qslf00Rm8CuHHzlNgh3oVB7hbFU/+ztWqYkIr0cyyozHKTF/j4jAapMI8RLk3Jy3HRi+q+epGwZjGsnVRNHiZYKDAcJhlBr6SsRJz/7uxjmGO8Wh9zjAdV/MdE2Z8xamhHgNrYlqfUT4TZl2bIb6JCrXy+Z7Pga9k+8ergHkF348Uy+ngluELG+DXKRjwsAWzRbfWc6OIM5g2fKP+NbiyGVu6lzoe6T9e6HIVrnbO4S/7Fpat4gkz3xC/rO4H3e/i7In2h4g+j+rAAeZsj0R7poIQKb6p1QPw== shadeslayer@saphira'
  ]
  apiport 8080
end

include_recipe 'bsw_gpg::default'
bsw_gpg_load_key_from_string 'a string key' do
  key_contents KeyBag.load('dci.private.key')
  for_user 'dci'
end
