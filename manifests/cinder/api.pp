class mazut::cinder::api(){
  $user_password    = hiera('mazut::cinder_user_password')
  $db_host          = hiera('mazut::mysql_host')
  $db_password      = hiera('mazut::cinder_db_password') 
  $glance_host      = hiera('mazut::controller_priv_host')    
  $amqp_hosts       = hiera('mazut::amqp_hosts')
  $amqp_port        = hiera('mazut::amqp_port')       
  $amqp_username    = hiera('mazut::amqp_username')  
  $amqp_password    = hiera('mazut::amqp_password')   
  $debug            = hiera('mazut::debug')
  $verbose          = hiera('mazut::verbose')
  $region           = hiera('mazut::region')
  $db_name          = 'cinder'         
  $db_user          = 'cinder'         
  $max_retries      = ''
  $keystone_host    = hiera('mazut::controller_priv_host')
  $use_syslog       = false
  $log_facility     = 'LOG_USER'
  $backup_swift_url = ''
  $rabbit_hosts     = suffix($amqp_hosts,":$amqp_port")
  $service_iface    = hiera('mazut::service_iface','eth0')
  $service_ip       = pick(get_ip_from_nic("$service_iface"),$::ipaddress)

  class {'mazut::cinder::auth':}
  class {'mazut::cinder::auth_v2':}
  #$rpc_backend      = 'cinder.openstack.common.rpc.impl_kombu',     
  $rpc_backend = amqp_backend('cinder', 'rabbitmq')

  cinder_config {
    'DEFAULT/glance_host': value => $glance_host;
    'DEFAULT/notification_driver': value => 'cinder.openstack.common.notifier.rpc_notifier'
  }
  if $max_retries {
    cinder_config {
      'DEFAULT/max_retries':      value => $max_retries;
    }
  }

  $sql_connection = "mysql://${db_user}:${db_password}@${db_host}/${db_name}"

  class {'::cinder':
    rpc_backend         => $rpc_backend,
    rabbit_hosts        => $rabbit_hosts,
    rabbit_port         => $amqp_port,
    rabbit_userid       => $amqp_username,
    rabbit_password     => $amqp_password,
    database_connection => $sql_connection,
    verbose             => str2bool_i("$verbose"),
    debug               => str2bool_i("$debug"),
    use_syslog          => str2bool_i("$use_syslog"),
    log_facility        => $log_facility,
  }

  class {'::cinder::api':
    keystone_password  => $user_password,
    keystone_tenant    => "services",
    keystone_user      => "cinder",
    keystone_auth_host => $keystone_host,
    auth_uri           => "http://${keystone_host}:5000/",
    enabled            => true,
    bind_host          => $service_ip,
    os_region_name     => $region,
  }

  class {'::cinder::scheduler':
    enabled => true,
  }

  class {'::cinder::backup::swift':
    backup_swift_url   => $backup_swift_url,
  }
}
