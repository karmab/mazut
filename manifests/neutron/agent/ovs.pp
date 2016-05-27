class mazut::neutron::agent::ovs (){
  $enable_tunneling             = hiera('mazut::enable_tunneling')
  $mysql_host                   = hiera('mazut::mysql_host')
  $neutron_db_password          = hiera('mazut::neutron_db_password')
  $ovs_bridge_mappings          = hiera('mazut::ovs_bridge_mappings')
  $ovs_bridge_uplinks           = hiera('mazut::ovs_bridge_uplinks')
  $ovs_vlan_ranges              = hiera('mazut::ovs_vlan_ranges',undef)
  $ovs_tunnel_iface             = hiera('mazut::ovs_tunnel_iface')
  $ovs_tunnel_network           = hiera('mazut::ovs_tunnel_network')
  $ovs_l2_population            = hiera('mazut::ovs_l2_population')
  $tenant_network_type          = hiera('mazut::tenant_network_type')
  $tunnel_id_ranges             = hiera('mazut::tunnel_id_ranges')
  $ovs_vxlan_udp_port           = hiera('mazut::ovs_vxlan_udp_port')
  $ovs_tunnel_types             = hiera('mazut::ovs_tunnel_types')

  $sql_connection = "mysql://neutron:${neutron_db_password}@${mysql_host}/neutron"
  #class { '::neutron::plugins::ovs':
  #  sql_connection      => $sql_connection,
  #  tenant_network_type => $tenant_network_type,
  #  network_vlan_ranges => $ovs_vlan_ranges,
  #  tunnel_id_ranges    => $tunnel_id_ranges,
  #  vxlan_udp_port      => $ovs_vxlan_udp_port,
  #}

  if ! defined ( Package['neutron-plugin-ml2'] ) {
    file { '/etc/neutron/plugins/ml2': ensure => directory; }
  }
  file {'/etc/neutron/plugins/openvswitch/ovs_neutron_plugin.ini':
    ensure  => link,
    target  => '/etc/neutron/plugins/ml2/openvswitch_agent.ini',
    require => [Package['openstack-neutron-openvswitch']],
    notify  => Service['neutron-openvswitch-agent'],
  }
  $local_ip = find_ip("$ovs_tunnel_network","$ovs_tunnel_iface","")
  class { '::neutron::agents::ml2::ovs':
    enabled                    => true,
    bridge_uplinks             => $ovs_bridge_uplinks,
    bridge_mappings            => $ovs_bridge_mappings,
    enable_tunneling           => true,
    tunnel_types               => $ovs_tunnel_types,
    local_ip                   => $local_ip,
    vxlan_udp_port             => $ovs_vxlan_udp_port,
    l2_population              => $ovs_l2_population,
    #firewall_driver            => 'neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver',
    manage_vswitch             => true,
  }
}
