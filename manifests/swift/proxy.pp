class mazut::swift::proxy (){
  $keystone_host        = hiera('mazut::controller_priv_host')
  $swift_admin_password = hiera('mazut::swift_user_password')
  $swift_shared_secret  = hiera('mazut::swift_shared_secret')
  $swift_ringserver_ip  = hiera('mazut::swift_ringserver_ip')
  $swift_storage_ips    = hiera('mazut::swift_storage_ips')
  $swift_storage_device = hiera('mazut::swift_storage_device')
  $swift_is_ringserver  = true
  $service_iface        = hiera('mazut::service_iface','eth0')
  $service_ip           = pick(get_ip_from_nic("$service_iface"),$::ipaddress)
  # Todo for standalone case, enable openstack-swift-object-expirer,
  # expose param for concurrency (possibly in this class, possibly
  # a new class)

  package { 'curl': ensure => present }

  class { '::swift::proxy':
    proxy_local_net_ip => $service_ip,
    # it is not a mistake that proxy-logging is listed twice below.
    # for more on that, see
    # /usr/share/doc/openstack-swift-proxy-1.9.1/proxy-server.conf-sample
    pipeline           => [
      'healthcheck',
      'cache',
      'proxy-logging',
      'authtoken',
      'keystone',
      'proxy-logging',
      'proxy-server'
    ],
    account_autocreate => true,
    log_facility => 'LOG_LOCAL1',
  }

  # this declaration is needed so that the pipeline loop in
  # puppet-swift/manaifests/proxy.pp doesn't break.  note that
  # it ends up including the real logging class, proxy_logging
  class { '::swift::proxy::proxy_logging': }

  # configure all of the middlewares
  class { [
      '::swift::proxy::catch_errors',
      '::swift::proxy::healthcheck',
      '::swift::proxy::cache',
  ]: }

  class { '::swift::proxy::ratelimit':
      clock_accuracy         => 1000,
      max_sleep_time_seconds => 60,
      log_sleep_time_seconds => 0,
      rate_buffer_seconds    => 5,
      account_ratelimit      => 0
  }

  class { '::swift::proxy::keystone':
      operator_roles => ['admin', 'SwiftOperator'],
  }

  class { '::swift::proxy::authtoken':
      admin_user        => 'swift',
      admin_tenant_name => 'services',
      admin_password    => $swift_admin_password,
      # assume that the controller host is the swift api server
      auth_host         => $keystone_host,
  }

  class {'mazut::swift::common':}

  if str2bool_i("$swift_is_ringserver") {

    # purposely using swift::ringbuilder::create, not
    # swift::ringbuilder since plain-old swift::ringbuilder does
    # things like rebalance the rings which we are taking care of in
    # swift_ring_build_helper.

    swift::ringbuilder::create{ ['object', 'account', 'container']:
      part_power     => '18',
      replicas       => '3',
      min_part_hours => '1',
      require        => Class['mazut::swift::common'],
    }
    ->
    swift_ring_build_helper { "build the swift rings":
      ensure               => "present",
      swift_storage_ips    => $swift_storage_ips,
      swift_storage_device => $swift_storage_device,
    } ->

    # "swift_server" since that is the module storage nodes look for
    mazut::rsync::simple { "swift_server":
      path         => '/etc/swift',
      bind_addr    => "$swift_ringserver_ip",
      uid => 'swift',
      gid => 'swift',
      max_connections => 10,
    }
  } else {

    swift::ringsync{["account","container","object"]:
      ring_server => $swift_ringserver_ip,
      before => Class['swift::proxy'],
      require => Class['swift'],
    }
    if ($::selinux != "false"){
        selboolean{'rsync_client':
            value => on,
            persistent => true,
        }
    }
  }
}
