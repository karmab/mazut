class mazut::ceilometer::api() {

  $ceilometer_metering_secret = hiera('mazut::ceilometer_metering_secret')
  $ceilometer_user_password   = hiera('mazut::ceilometer_user_password')
  $controller_admin_host      = hiera('mazut::controller_admin_host')
  $controller_priv_host       = hiera('mazut::controller_priv_host')
  $controller_pub_host        = hiera('mazut::controller_pub_host')
  $verbose                    = hiera('mazut::verbose')
  $debug                      = hiera('mazut::debug')
  $mongoservers               = hiera('mazut::mongodb_servers')
  $set_replica                = hiera('mazut::mongodb_replica')
  $connections                = join($mongoservers,',')
  $service_iface                 = hiera('mazut::service_iface','eth0')
  $service_ip                    = pick(get_ip_from_nic("$service_iface"),$::ipaddress)

  if $set_replica {
      $replicaset          = hiera('mazut::mongodb_replicaset')
      $database_connection = "mongodb://${connections}/ceilometer?replicaSet=$replicaset"
  } else {
      $database_connection = "mongodb://${connections}/ceilometer"
  }

  class {'mazut::ceilometer::auth':}
  class { '::ceilometer::db':
      database_connection => $database_connection,
      #require             => Service['mongod'],
  }

  if ! defined(Class['mazut::ceilometer::core']){
    class { '::mazut::ceilometer::core':}
  }

  class { '::ceilometer::collector':
      require => Class['ceilometer::db'],
  }

  class { '::ceilometer::agent::notification':}

  class { '::ceilometer::agent::central':
      enabled => true,
  }

  class { '::ceilometer::alarm::notifier':
  }

  class { '::ceilometer::alarm::evaluator':
  }

  class { '::ceilometer::api':
      keystone_host     => $controller_priv_host,
      keystone_password => $ceilometer_user_password,
      host              => $service_ip,
      #require             => Service['mongod'],
  }
}
