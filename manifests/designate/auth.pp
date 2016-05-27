class mazut::designate::auth () {
  $controller_admin_host         = hiera('mazut::controller_admin_host')
  $controller_priv_host          = hiera('mazut::controller_priv_host')
  $controller_pub_host           = hiera('mazut::controller_pub_host')
  $password                      = hiera('mazut::designate_user_password')
  $public_url                    = hiera('mazut::public_url_designate')
  $region                        = hiera('mazut::region')
  $ldap                          = hiera('mazut::enable_ldap')
  $user                          = 'designate'
  $service                       = 'designate'
  $type                          = 'dns'
  $description                   = 'Openstack DNSaas Service'
  $roles                         = ['admin']
  $admin_url                     = "http://$controller_admin_host:9001/v1"
  $internal_url                  = "http://$controller_priv_host:9001/v1"
  $public                        = pick($public_url,$internal_url)
  $final_password                = $ldap ? { false  => $password, true => undef }

  class { 'designate::keystone::auth':
    password            => $final_password,
    auth_name           => $service,
    service_name        => $service,
    service_type        => $type,
    service_description => $description,
    region              => $region,
    tenant              => 'services',
    configure_endpoint  => true,
    public_url          => $admin_url,
    admin_url           => $admin_url,
    internal_url        => $internal_url,
  } 
}
