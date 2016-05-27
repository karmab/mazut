class mazut::heat::auth_cfn {
  $controller_admin_host         = hiera('mazut::controller_admin_host')
  $controller_priv_host          = hiera('mazut::controller_priv_host')
  $controller_pub_host           = hiera('mazut::controller_pub_host')
  $public_url                    = hiera('mazut::public_url_heat_cfn')
  $region                        = hiera('mazut::region')
  $service                       = 'heat-cfn'
  $type                          = 'cloudformation'
  $description                   = 'Openstack Cloudformation Service'
  $admin_url                     = "http://$controller_admin_host:8000/v1"
  $internal_url                  = "http://$controller_priv_host:8000/v1"
  $url                           = pick($public_url,"http://$controller_priv_host:8000")
  $public                        = "$url/v1"

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
