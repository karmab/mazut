class mazut::nova::api (){
  $controller_admin_host         = hiera('mazut::controller_admin_host')
  $controller_priv_host          = hiera('mazut::controller_priv_host')
  $controller_pub_host           = hiera('mazut::controller_pub_host')
  $neutron_metadata_proxy_secret = hiera('mazut::neutron_metadata_proxy_secret')
  $mysql_host                    = hiera('mazut::mysql_host')
  $mysql_root_password           = hiera('mazut::mysql_root_password')
  $nova_db_password              = hiera('mazut::nova_db_password')
  $nova_user_password            = hiera('mazut::nova_user_password')
  $nova_default_floating_pool    = hiera('mazut::nova_default_floating_pool')
  $nfv                           = hiera('mazut::enable_nfv')
  $verbose                       = hiera('mazut::verbose')
  $debug                         = hiera('mazut::debug')
  $service_iface                 = hiera('mazut::service_iface','eth0')
  $service_ip                    = pick(get_ip_from_nic("$service_iface"),$::ipaddress)
  $pci_alias                     = $nfv ? { false => undef , true => hiera('mazut::pci_alias') }

  if !empty($private_ip) {
      nova_config {
          'DEFAULT/my_ip':      value => $private_ip;
      }
  }
  class {'mazut::nova::auth':}
  class {'mazut::nova::auth_ec2':}
  if ! defined(Class['mazut::nova::core']){
    class {'mazut::nova::core':}
  }

  class { '::nova::api':
    enabled             => true,
    admin_password      => $nova_user_password,
    auth_host           => $controller_priv_host,
    neutron_metadata_proxy_shared_secret => $neutron_metadata_proxy_secret,
    api_bind_address    => $service_ip,
    metadata_listen     => $service_ip,
    cinder_catalog_info => 'volumev2:cinderv2:internalURL',
    pci_alias           => $pci_alias,
  }

  class { [ '::nova::scheduler', '::nova::cert', '::nova::consoleauth', '::nova::conductor' ]:
    enabled => true,
  }
  if $nfv {
    class { '::nova::scheduler::filter':
      scheduler_default_filters  => ['RetryFilter,AvailabilityZoneFilter,RamFilter,ComputeFilter,ComputeCapabilitiesFilter,ImagePropertiesFilter,CoreFilter,NUMATopologyFilter','PciPassthroughFilter'],
      cpu_allocation_ratio       => '1.0',
      ram_allocation_ratio       => '1.0',
    }
  }
  class { '::nova::vncproxy':
    host              => $service_ip,
    enabled           => true,
  }
}
