class mazut::neutron::client (){
  $auth_host                    = hiera('mazut::controller_priv_host')
  $nova_host                    = hiera('mazut::controller_priv_host')
  $enable_tunneling             = hiera('mazut::enable_tunneling')
  $mysql_host                   = hiera('mazut::mysql_host')
  $neutron_db_password          = hiera('mazut::neutron_db_password')
  $neutron_host                 = hiera('mazut::controller_priv_host')
  $nova_user_password           = hiera('mazut::nova_user_password')
  $ovs_bridge_mappings          = hiera('mazut::ovs_bridge_mappings')
  $ovs_bridge_uplinks           = hiera('mazut::ovs_bridge_uplinks')
  $ovs_vlan_ranges              = hiera('mazut::ovs_vlan_ranges',undef)
  $ovs_tunnel_iface             = hiera('mazut::ovs_tunnel_iface')
  $ovs_tunnel_network           = hiera('mazut::ovs_tunnel_network')
  $ovs_l2_population            = hiera('mazut::ovs_l2_population')
  $amqp_port                    = hiera('mazut::amqp_port')
  $amqp_hosts                   = hiera('mazut::amqp_hosts')
  $amqp_username                = hiera('mazut::amqp_username')
  $amqp_password                = hiera('mazut::amqp_password')
  $tenant_network_type          = hiera('mazut::tenant_network_type')
  $tunnel_id_ranges             = hiera('mazut::tunnel_id_ranges')
  $ovs_vxlan_udp_port           = hiera('mazut::ovs_vxlan_udp_port')
  $ovs_tunnel_types             = hiera('mazut::ovs_tunnel_types')
  $verbose                      = hiera('mazut::verbose')
  $debug                        = hiera('mazut::debug')
  $sql_connection               = "mysql://neutron:${neutron_db_password}@${mysql_host}/neutron"
  $rabbit_hosts                 = suffix($amqp_hosts,":$amqp_port")

  class { '::neutron':
    allow_overlapping_ips => true,
    rpc_backend           => 'neutron.openstack.common.rpc.impl_kombu',
    rabbit_hosts          => $rabbit_hosts,
    rabbit_port           => $amqp_port,
    rabbit_user           => $amqp_username,
    rabbit_password       => $amqp_password,
    verbose               => $verbose,
    debug                 => $debug,
  }
  ->
  class { '::neutron::server::notifications':
    notify_nova_on_port_status_changes => true,
    notify_nova_on_port_data_changes   => true,
    nova_url                           => "http://${nova_host}:8774/v2",
    nova_admin_auth_url                => "http://${auth_host}:35357/v2.0",
    nova_admin_username                => "nova",
    nova_admin_password                => "${nova_user_password}",
  }

  neutron_config {
    'database/connection':                  value => $sql_connection;
    'keystone_authtoken/auth_host':         value => $auth_host;
    'keystone_authtoken/admin_tenant_name': value => 'services';
    'keystone_authtoken/admin_user':        value => 'neutron';
    'keystone_authtoken/admin_password':    value => $neutron_user_password;
  }

  class { '::neutron::plugins::ml2::ovs':
    sql_connection      => $sql_connection,
    tenant_network_type => $tenant_network_type,
    network_vlan_ranges => $ovs_vlan_ranges,
    tunnel_id_ranges    => $tunnel_id_ranges,
    vxlan_udp_port      => $ovs_vxlan_udp_port,
  }

  neutron_plugin_ovs { 'AGENT/l2_population': value => "$ovs_l2_population"; }
#
  $local_ip = find_ip("$ovs_tunnel_network","$ovs_tunnel_iface","")
  class { '::neutron::agents::ovs':
    bridge_uplinks   => $ovs_bridge_uplinks,
    bridge_mappings  => $ovs_bridge_mappings,
    local_ip         => $local_ip,
    enable_tunneling => str2bool_i("$enable_tunneling"),
    tunnel_types     => $ovs_tunnel_types,
    vxlan_udp_port   => $ovs_vxlan_udp_port,
  }

  class { '::nova::network::neutron':
    neutron_admin_password => $neutron_user_password,
    neutron_url            => "http://${neutron_host}:9696",
    neutron_admin_auth_url => "http://${auth_host}:35357/v2.0",
    neutron_ovs_bridge     => 'alubr0',
  }

}
