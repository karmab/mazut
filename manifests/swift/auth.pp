class mazut::swift::auth (){
  $controller_admin_host         = hiera('mazut::controller_admin_host')
  $controller_priv_host          = hiera('mazut::controller_priv_host')
  $controller_pub_host           = hiera('mazut::controller_pub_host')
  $password                      = hiera('mazut::swift_user_password')
  $public_url                    = hiera('mazut::public_url_swift')
  $region                        = hiera('mazut::region')
  $ldap                          = hiera('mazut::enable_ldap')
  $user                          = 'swift'
  $service                       = 'swift'
  $type                          = 'object-store'
  $description                   = 'Openstack Object-Store Service'
  $roles                         = ['admin','SwiftOperator']
  $admin_url                     = "http://$controller_admin_host:8080"
  $internal_url                  = "http://$controller_priv_host:8080/v1/AUTH_%(tenant_id)s"
  $url                           = pick($public_url,"http://$controller_priv_host:8080")
  $public                        = "$url/v1/AUTH_%(tenant_id)s"
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
