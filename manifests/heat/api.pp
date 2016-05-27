class mazut::heat::api() {
  $auth_encryption_key     = hiera('mazut::heat_auth_encrypt_key')
  $heat_cfn                = hiera('mazut::heat_cfn')
  $heat_cloudwatch         = hiera('mazut::heat_cloudwatch')
  $heat_user_password      = hiera('mazut::heat_user_password')
  $heat_db_password        = hiera('mazut::heat_db_password')
  $controller_admin_host   = hiera('mazut::controller_admin_host')
  $controller_priv_host    = hiera('mazut::controller_priv_host')
  $controller_pub_host     = hiera('mazut::controller_pub_host')
  $mysql_host              = hiera('mazut::mysql_host')
  $amqp_port               = hiera('mazut::amqp_port')
  $amqp_hosts              = hiera('mazut::amqp_hosts')
  $amqp_username           = hiera('mazut::amqp_username')
  $amqp_password           = hiera('mazut::amqp_password')
  $verbose                 = hiera('mazut::verbose')
  $debug                   = hiera('mazut::debug')
  $rabbit_hosts            = suffix($amqp_hosts,":$amqp_port")
  $service_iface           = hiera('mazut::service_iface','eth0')
  $service_ip              = pick(get_ip_from_nic("$service_iface"),$::ipaddress)

  class {'mazut::heat::auth':}
  class {'mazut::heat::auth_cfn':}
  $sql_connection = "mysql://heat:${heat_db_password}@${mysql_host}/heat"

  class { '::heat':
      keystone_host     => $controller_priv_host,
      keystone_password => $heat_user_password,
      auth_uri          => "http://${controller_admin_host}:35357/v2.0",
      rpc_backend       => 'rabbit',
      rabbit_hosts      => $rabbit_hosts,
      rabbit_port       => $amqp_port,
      rabbit_userid     => $amqp_username,
      rabbit_password   => $amqp_password,
      verbose           => $verbose,
      debug             => $debug,
      sql_connection    => $sql_connection,
  }

  class { '::heat::api_cfn':
      enabled   => str2bool_i("$heat_cfn"),
      bind_host => $service_ip,
  }

  class { '::heat::api_cloudwatch':
      enabled   => str2bool_i("$heat_cloudwatch"),
      bind_host => $service_ip,
  }

  class { '::heat::engine':
      auth_encryption_key           => $auth_encryption_key,
      heat_metadata_server_url      => "http://${controller_priv_host}:8000",
      heat_waitcondition_server_url => "http://${controller_priv_host}:8000/v1/waitcondition",
      heat_watch_server_url         => "http://${controller_priv_host}:8003",
  }

  class { '::heat::api':
      bind_host         => $service_ip,
  }

  heat_config {
      'clients/endpoint_type':           value => 'internalURL';
      'clients_nova/endpoint_type':      value => 'internalURL';
  }

}
