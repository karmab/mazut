# == Class: mazut::profiles::networker
#
# networker profile class
#
class mazut::profiles::networker () {
  $debug                  = hiera('mazut::debug')
  $auth_password          = hiera('mazut::neutron_user_password')
  $shared_secret          = hiera('mazut::neutron_metadata_proxy_secret')
  $auth_ip                = hiera('mazut::controller_priv_host')
  $metadata_ip            = hiera('mazut::controller_priv_host')
  $extra_network_services = hiera('mazut::extra_network_services')
 
  if 'dhcp' in $extra_network_services {
    class { '::neutron::agents::dhcp': debug => $debug,}
  }
  if 'l3' in $extra_network_services {
    class { '::neutron::agents::l3': debug => $debug,}
  }
  if 'metadata' in $extra_network_services {
    class { 'neutron::agents::metadata':
      debug         => $debug,
      auth_password => $auth_password,
      shared_secret => $shared_secret,
      auth_url      => "http://${auth_ip}:35357/v2.0",
      metadata_ip   => $metadata_ip,
    }  
  }
  if 'fwaas' in $extra_network_services {
    class { '::neutron::services::fwaas':}
  }
  if 'lbaas' in $extra_network_services {
    $interface_driver       = hiera('mazut::lbaas_interfacedriver','neutron.agent.linux.interface.OVSInterfaceDriver')
    class { '::neutron::agents::lbaas': 
      debug            => $debug, 
      interface_driver => $interface_driver,
    }
  }
}
