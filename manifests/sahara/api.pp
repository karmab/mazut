class mazut::sahara::api() {
  $sahara_user_password  = hiera('mazut::sahara_user_password')
  $sahara_db_password    = hiera('mazut::sahara_db_password')
  $controller_priv_host  = hiera('mazut::controller_priv_host')
  $mysql_host            = hiera('mazut::mysql_host')
  $verbose               = hiera('mazut::verbose')  
  $debug                 = hiera('mazut::debug')
  $region                = hiera('mazut::region')
  $api_version           = hiera('mazut::keystone_api_version')
  $service_iface         = hiera('mazut::service_iface','eth0')
  $service_ip            = pick(get_ip_from_nic("$service_iface"),$::ipaddress)

  class {'mazut::sahara::auth':}
  class { '::sahara':
    auth_uri            => "http://${controller_priv_host}:5000/${api_version}/",
    admin_password      => $sahara_user_password,
    verbose             => $verbose,
    debug               => $debug,
    host                => $service_ip,
    database_connection => "mysql://sahara:${sahara_db_password}@${mysql_host}/sahara",
    enabled             => true,
    identity_uri        => "http://${controller_priv_host}:35357/",
  }
}
