class mazut::designate::api (){
  $user_password            = hiera('mazut::designate_user_password')
  $db_password              = hiera('mazut::designate_db_password')
  $db_host                  = hiera('mazut::mysql_host')
  $verbose                  = hiera('mazut::verbose')
  $debug                    = hiera('mazut::debug') 
  $amqp_hosts               = hiera('mazut::amqp_hosts')
  $amqp_port                = hiera('mazut::amqp_port')
  $amqp_username            = hiera('mazut::amqp_username')
  $amqp_password            = hiera('mazut::amqp_password')
  $keystone_host            = hiera('mazut::controller_priv_host')
  $backend_driver           = hiera('mazut::designate_backend')
  $sql_idle_timeout         = '3600'
  $db_user                  = 'designate'
  $db_name                  = 'designate'
  $max_retries              = ''
  $use_syslog               = false
  $log_facility             = 'LOG_USER'
  $rabbit_hosts             = suffix($amqp_hosts,":$amqp_port")
 
  class { '::designate':
    common_package_name   => 'openstack-designate-common',
    verbose               => $verbose,
    debug                 => $debug,
    use_syslog            => $use_syslog,
    rabbit_hosts          => $rabbit_hosts,
    rabbit_userid         => $amqp_username,
    rabbit_password       => $amqp_password,
  }

  class {'::designate::db':
    database_connection   => "mysql://${db_user}:${db_password}@${db_host}/${db_name}"
  }

  include '::designate::client'
  class {'::designate::api':
    keystone_host     => $keystone_host,
    keystone_password => $user_password,
  }

  class {'::designate::central':
    backend_driver => $backend_driver,
    min_ttl        => 180,
  }

  include '::designate::dns'
  if $backend_driver == 'bind9' {
    class {'::designate::backend::bind9':
      rndc_config_file => '/etc/rndc.key',
      rndc_key_file    => '/etc/rndc.key',
    }
  }
  if $backend_driver == 'powerdns' {
    $powerdns_db_name     = 'powerdns'
    $powerdns_db_user     = 'powerdns'
    $powerdns_db_password = hiera('mazut::designate_powerdnspassword')
    $powerdns_db_name     = 'powerdns'
    class {'::designate::backend::powerdns':
      database_connection   => "mysql://${powerdns_db_user}:${powerdns_db_password}@${db_host}/${powerdns_db_name}"
    }
  }
  class { 'mazut::designate::auth':}
}
