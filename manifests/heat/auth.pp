class mazut::heat::auth {
  $controller_admin_host         = hiera('mazut::controller_admin_host')
  $controller_priv_host          = hiera('mazut::controller_priv_host')
  $controller_pub_host           = hiera('mazut::controller_pub_host')
  $password                      = hiera('mazut::heat_user_password')
  $public_url                    = hiera('mazut::public_url_heat')
  $region                        = hiera('mazut::region')
  $ldap                          = hiera('mazut::enable_ldap')
  $user                          = 'heat'
  $service                       = 'heat'
  $type                          = 'orchestration'
  $description                   = 'Openstack Orchestration Service'
  $roles                         = ['admin']
  $admin_url                     = "http://$controller_admin_host:8004/v1/%(tenant_id)s"
  $internal_url                  = "http://$controller_priv_host:8004/v1/%(tenant_id)s"
  $url                           = pick($public_url,"http://$controller_priv_host:8004")
  $public                        = "$url/v1/%(tenant_id)s"
  $final_password                = $ldap ? { false  => $password, true => undef }

  keystone_user { $user:
    ensure   => present,
    enabled  => true,
    password => $final_password, 
  }->
  keystone_user_role { "$user@services":
    ensure => present,
    roles  => $roles,
  }
  keystone_service { $service:
    ensure      => present,
    type        => $type,
    description => $description,
  }
  keystone_endpoint { "$region/$service":
    ensure       => present,
    public_url   => $public,
    admin_url    => $admin_url,
    internal_url => $internal_url,
  }
}
