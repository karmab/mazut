# compute node configuration for neutron (OpenStack Networking)
class mazut::ceilometer::core () {

  $auth_host                    = hiera('mazut::controller_priv_host')
  $ceilometer_metering_secret   = hiera('mazut::ceilometer_metering_secret')
  $ceilometer_user_password     = hiera('mazut::ceilometer_user_password')
  $amqp_port                    = hiera('mazut::amqp_port')
  $amqp_hosts                   = hiera('mazut::amqp_hosts')
  $amqp_username                = hiera('mazut::amqp_username')
  $amqp_password                = hiera('mazut::amqp_password')
  $verbose                      = hiera('mazut::verbose')
  $rabbit_hosts                 = suffix($amqp_hosts,":$amqp_port")

  class { 'ceilometer':
    metering_secret => $ceilometer_metering_secret,
    rabbit_hosts    => $rabbit_hosts,
    rabbit_port     => $amqp_port,
    rabbit_userid   => $amqp_username,
    rabbit_password => $amqp_password,
    rpc_backend     => 'ceilometer.openstack.common.rpc.impl_kombu',
    verbose         => $verbose,
  }

  class { 'ceilometer::agent::auth':
    auth_url      => "http://${auth_host}:35357/v2.0",
    auth_password => $ceilometer_user_password,
  }
  ceilometer_config {
    'service_credentials/os_endpoint_type': 
      value   => 'internalURL',
      require =>  Class['::ceilometer'],
  }

}
