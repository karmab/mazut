# compute node configuration for neutron (OpenStack Networking)
class mazut::ceilometer::compute () {

  $auth_host                    = hiera('mazut::controller_priv_host')
  $ceilometer_metering_secret   = hiera('mazut::ceilometer_metering_secret')
  $ceilometer_user_password     = hiera('mazut::ceilometer_user_password')
  $verbose                      = hiera('mazut::verbose')

  if ! defined(Class['mazut::ceilometer::core']){
    class { '::mazut::ceilometer::core':}
  }

  class { 'ceilometer::agent::compute':
    enabled => true,
  }
  Package['openstack-nova-common'] -> Package['ceilometer-common']
}
