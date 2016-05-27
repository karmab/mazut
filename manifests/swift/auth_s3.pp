class mazut::swift::auth_s3 (){
  $controller_admin_host         = hiera('mazut::controller_admin_host')
  $controller_priv_host          = hiera('mazut::controller_priv_host')
  $controller_pub_host           = hiera('mazut::controller_pub_host')
  $public_url                    = hiera('mazut::public_url_swift')
  $region                        = hiera('mazut::region')
  $service                       = 'swift_s3'
  $type                          = 's3'
  $description                   = 'Openstack S3 Service'
  $admin_url                     = "http://$controller_admin_host:8080"
  $internal_url                  = "http://$controller_priv_host:8080"
  $url                           = pick($public_url,"http://$controller_priv_host:8080")
  $public                        = "$url"

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
