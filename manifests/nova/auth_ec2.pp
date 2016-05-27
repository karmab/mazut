class mazut::nova::auth_ec2 (){
  $controller_admin_host         = hiera('mazut::controller_admin_host')
  $controller_priv_host          = hiera('mazut::controller_priv_host')
  $controller_pub_host           = hiera('mazut::controller_pub_host')
  $public_url                    = hiera('mazut::public_url_nova_ec2')
  $region                        = hiera('mazut::region')
  $service                       = 'ec2'
  $type                          = 'ec2'
  $description                   = 'EC2 Compatibility Layer'
  $admin_url                     = "http://$controller_admin_host:8773/services/Admin"
  $internal_url                  = "http://$controller_priv_host:8773/services/Cloud"
  $url                           = pick($public_url,"http://$controller_priv_host:8773")
  $public                        = "$url/services/Cloud"

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
