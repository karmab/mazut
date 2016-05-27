class mazut::cinder::auth_v2 (){
  $controller_admin_host         = hiera('mazut::controller_admin_host')
  $controller_priv_host          = hiera('mazut::controller_priv_host')
  $controller_pub_host           = hiera('mazut::controller_pub_host')
  $public_url                    = hiera('mazut::public_url_cinder')
  $region                        = hiera('mazut::region')
  $service                       = 'cinderv2'
  $type                          = 'volumev2'
  $description                   = 'Cinder Service V2' 
  $admin_url                     = "http://$controller_admin_host:8776/v2/\$(tenant_id)s"
  $internal_url                  = "http://$controller_priv_host:8776/v2/\$(tenant_id)s"
  $url                           = pick($public_url,"http://$controller_priv_host:8776")
  $public                        = "$url/v2/\$(tenant_id)s"

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
