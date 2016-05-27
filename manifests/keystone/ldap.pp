class mazut::keystone::ldap () {
  $url                    = hiera('mazut::ldap_url')
  $tree_dn                = hiera('mazut::ldap_tree_dn')
  $user_id_attribute      = hiera('mazut::ldap_user_id_attribute','uid')
  $user_name_attribute    = hiera('mazut::ldap_user_name_attribute','uid')
  $user_mail_attribute    = hiera('mazut::ldap_user_mail_attribute','mail')
  $user_enabled_attribute = hiera('mazut::ldap_user_enabled_attribute','nsAccountLock')
  $user                   = hiera('mazut::ldap_user',undef)
  $password               = hiera('mazut::ldap_password',undef)
  $tls_cacertfile         = hiera('mazut::ldap_tls_cacertfile',undef)

  class { '::keystone::ldap':
    assignment_driver      => 'keystone.assignment.backends.sql.Assignment',
    identity_driver        => 'keystone.identity.backends.ldap.Identity',
    url                    => $url,
    user                   => $user,
    password               => $password,
    tls_cacertfile         => $tls_cacertfile,
    user_tree_dn           => $tree_dn,
    user_id_attribute      => $user_id_attribute,
    user_name_attribute    => $user_name_attribute,
    user_mail_attribute    => $user_mail_attribute,
    user_enabled_attribute => $user_enabled_attribute,
    user_enabled_default   => 'False',
    user_enabled_invert    => true,
    user_allow_create      => false,
    user_allow_update      => false,
    user_allow_delete      => false,
  }
}

