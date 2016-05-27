class mazut::glance::api (){
  $user_password            = hiera('mazut::glance_user_password')
  $db_password              = hiera('mazut::glance_db_password')
  $db_host                  = hiera('mazut::mysql_host')
  $backend                  = hiera('mazut::glance_backend') 
  $rbd_store_user           = hiera('mazut::glance_rbd_store_user') 
  $rbd_store_pool           = hiera('mazut::glance_rbd_store_pool')
  $verbose                  = hiera('mazut::verbose')
  $debug                    = hiera('mazut::debug') 
  $amqp_hosts               = hiera('mazut::amqp_hosts')
  $amqp_port                = hiera('mazut::amqp_port')
  $amqp_username            = hiera('mazut::amqp_username')
  $amqp_password            = hiera('mazut::amqp_password')
  $provision_glance         = hiera('mazut::provision_glance')
  $cirros_version           = hiera('mazut::cirros_version')
  $glance_nfs_url           = hiera('mazut::glance_nfs_url')
  $mutiple_endpoints        = hiera('mazut::multiple_endpoints')
  $keystone_host            = hiera('mazut::controller_priv_host')
  $sql_idle_timeout         = '3600'
  $db_user                  = 'glance'
  $db_name                  = 'glance'
  $max_retries              = ''
  $swift_store_user         = ''
  $swift_store_key          = ''
  $swift_store_auth_address = ''
  $use_syslog               = false
  $log_facility             = 'LOG_USER'
  $filesystem_store_datadir = '/var/lib/glance/images/'
  $rabbit_hosts             = suffix($amqp_hosts,":$amqp_port")
  $service_iface            = hiera('mazut::service_iface','eth0')
  $service_ip               = pick(get_ip_from_nic("$service_iface"),$::ipaddress)

  class {'mazut::glance::auth':}
  # Configure the db string
  $sql_connection = "mysql://${db_user}:${db_password}@${db_host}/${db_name}"

  $show_image_direct_url = $backend ? {
    'rbd' => true,
    default => false,
  }

  # Install and configure glance-api
  class { '::glance::api':
    verbose               => $verbose,
    debug                 => $debug,
    registry_host         => $service_ip,
    bind_host             => $service_ip,
    auth_type             => 'keystone',
    auth_port             => '35357',
    auth_host             => $keystone_host,
    keystone_tenant       => 'services',
    keystone_user         => 'glance',
    keystone_password     => $user_password,
    database_connection   => $sql_connection,
    database_idle_timeout => $sql_idle_timeout,
    use_syslog            => $use_syslog,
    log_facility          => $log_facility,
    enabled               => true,
    show_image_direct_url => $show_image_direct_url,
  }

  # Install and configure glance-registry
  class { '::glance::registry':
    verbose               => $verbose,
    debug                 => $debug,
    bind_host             => $service_ip,
    auth_host             => $keystone_host,
    auth_port             => '35357',
    auth_type             => 'keystone',
    keystone_tenant       => 'services',
    keystone_user         => 'glance',
    keystone_password     => $user_password,
    database_connection   => $sql_connection,
    database_idle_timeout => $sql_idle_timeout,
    use_syslog            => $use_syslog,
    log_facility          => $log_facility,
    enabled               => true,
  }

  if $max_retries {
    glance_api_config {
      'DEFAULT/max_retries':      value => $max_retries;
    }
    glance_registry_config {
      'DEFAULT/max_retries':      value => $max_retries;
    }
  }

    class { '::glance::notify::rabbitmq':
      rabbit_password => $amqp_password,
      rabbit_userid   => $amqp_username,
      rabbit_hosts    => $rabbit_hosts,
      rabbit_port     => $amqp_port,
    }

  # Configure file storage backend
  if($backend == 'swift') {
    if ! $swift_store_user {
      fail('swift_store_user must be set when configuring swift as the glance backend')
    }
    if ! $swift_store_key {
      fail('swift_store_key must be set when configuring swift as the glance backend')
    }

    class { '::glance::backend::swift':
      swift_store_user                    => $swift_store_user,
      swift_store_key                     => $swift_store_key,
      swift_store_auth_address            => $swift_store_auth_address,
      swift_store_create_container_on_put => true,
    }
  } elsif($backend == 'file') {
    class { '::glance::backend::file':
      filesystem_store_datadir => $filesystem_store_datadir,
    }
  } elsif($backend == 'rbd') {
    class { '::glance::backend::rbd':
      rbd_store_user => $rbd_store_user,
      rbd_store_pool => $rbd_store_pool,
    }
  } else {
    fail("Unsupported backend ${backend}")
  }

  if $backend == 'nfs' and $glance_nfs_url {
    if ! defined(Package['nfs-utils']) {
     package {'nfs-utils': ensure => present,}
    }
    mount { '/var/lib/glance':
      device  => $glance_nfs_url,
      fstype  => 'nfs',
      ensure  => 'mounted',
      options => 'defaults,context=system_u:object_r:glance_var_lib_t:s0',
      atboot  => true,
    }
    file {'/var/lib/glance':
     ensure  => directory,
     owner   => 'glance',
     group   => 'glance',
     notify  => Service['openstack-glance-api'],
     require => Mount['/var/lib/glance'],
    }
  }

  if $provision_glance and ! $multiple_endpoints {
    glance_image { 'cirros':
      ensure           => present,
      container_format => 'bare',
      disk_format      => 'qcow2',
      is_public        => 'yes',
      source           => "http://download.cirros-cloud.net/${cirros_version}/cirros-${cirros_version}-x86_64-disk.img",
    }
  }
}
