class mazut::neutron::provision (){
  $provision_keystone            = hiera('mazut::provision_keystone')
  $provision_tenant              = hiera('mazut::provision_tenant')
  $neutron_public_net            = hiera('mazut::neutron_public_net')
  $neutron_public_gateway        = hiera('mazut::neutron_public_gateway')
  $neutron_public_start          = hiera('mazut::neutron_public_start')
  $neutron_public_end            = hiera('mazut::neutron_public_end')
  if $provision_keystone {
   $tenant = $provision_tenant
  }else{
   $tenant = 'admin'
  }
 neutron_network { 'private':
   tenant_name     => $tenant,
   router_external => false,
   require         => Service['neutron-ovs-agent-service'],
 }
 neutron_subnet { 'private':
   cidr             => '192.168.0.0/24',
   ip_version       => '4',
   allocation_pools => ['start=192.168.0.2,end=192.168.0.254'],
   gateway_ip       => '192.168.0.1',
   enable_dhcp      => true,
   network_name     => 'private',
   tenant_name      => $tenant,
   require          => Service['neutron-ovs-agent-service'],
 }
 if $neutron_public_net and  $neutron_public_gateway and $neutron_public_start and $neutron_public_end {
   neutron_network { 'public':
     tenant_name     => 'admin',
     router_external => true,
   }
   neutron_subnet { 'public':
     cidr             => $neutron_public_net,
     ip_version       => '4',
     allocation_pools => ["start=$neutron_public_start,end=$neutron_public_end"],
     gateway_ip       => $neutron_public_gateway,
     enable_dhcp      => false,
     network_name     => 'public',
     tenant_name      => 'admin',
   }
   neutron_router {'router':
     gateway_network_name => 'public',
     tenant_name          => $tenant,
   }
   neutron_router_interface {'router:private':
     ensure => present,
   }
 }
}
