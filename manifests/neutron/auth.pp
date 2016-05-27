class mazut::neutron::auth (){
  $controller_admin_host         = hiera('mazut::controller_admin_host')
  $controller_priv_host          = hiera('mazut::controller_priv_host')
  $controller_pub_host           = hiera('mazut::controller_pub_host')
  $password                      = hiera('mazut::neutron_user_password')
  $public_url                    = hiera('mazut::public_url_neutron')
  $region                        = hiera('mazut::region')
  $ldap                          = hiera('mazut::enable_ldap')
  $user                          = 'neutron'
  $service                       = 'neutron'
  $type                          = 'network'
  $description                   = 'Neutron Networking Service'
  $roles                         = ['admin']
  $admin_url                     = "http://$controller_admin_host:9696"
  $internal_url                  = "http://$controller_priv_host:9696"
  $public                        = pick($public_url,$internal_url)
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
