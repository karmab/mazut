class mazut::neutron::api (){
  $controller_admin_host         = hiera('mazut::controller_admin_host')
  $controller_priv_host          = hiera('mazut::controller_priv_host')
  $controller_pub_host           = hiera('mazut::controller_pub_host')
  $keystone_admin_token          = hiera('mazut::keystone_admin_token')
  $neutron_metadata_proxy_secret = hiera('mazut::neutron_metadata_proxy_secret')
  $mysql_host                    = hiera('mazut::mysql_host')
  $mysql_root_password           = hiera('mazut::mysql_root_password')
  $neutron_db_password           = hiera('mazut::neutron_db_password')
  $neutron_user_password         = hiera('mazut::neutron_user_password')
  $nova_user_password            = hiera('mazut::nova_user_password')
  $nova_default_floating_pool    = hiera('mazut::nova_default_floating_pool')
  $enable_tunneling              = hiera('mazut::enable_tunneling')
  $amqp_port                     = hiera('mazut::amqp_port')
  $agent_type                    = hiera('mazut::agent_type')
  $neutron_core_plugin           = hiera('mazut::neutron_core_plugin')
  $provision_keystone            = hiera('mazut::provision_keystone')
  $provision_tenant              = hiera('mazut::provision_tenant')
  $provision_neutron             = hiera('mazut::provision_neutron')
  $ml2_mechanism_drivers         = hiera('mazut::neutron_ml2_mechanism_drivers')
  $multiple_endpoints            = hiera('mazut::multiple_endpoints')
  $nfv                           = hiera('mazut::enable_nfv')
  $supported_pci_vendor_devs     = $nfv ? { false => undef , true => hiera('mazut::pci_vendor_devs') }
  $tunnel_id_ranges              = '1:1000'
  $ml2_type_drivers              = ['vxlan', 'flat','vlan','gre','local']
  $ml2_tenant_network_types      = ['vxlan', 'flat','vlan','gre']
  $ml2_flat_networks             = ['*']
  $ml2_network_vlan_ranges       = ['physnet1:1000:2999']
  $ml2_tunnel_id_ranges          = ['20:100']
  $ml2_vxlan_group               = '224.0.0.1'
  $ml2_vni_ranges                = ['10:100']
  $ml2_security_group            = 'true'
  $ml2_firewall_driver           = 'neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver'
  $security_group_api            = 'neutron'
  $neutron_ovs_bridge            = 'br-int'

  class {'mazut::neutron::auth':}
  $sql_connection = "mysql://neutron:${neutron_db_password}@${mysql_host}/neutron"

  if ! defined(Class['mazut::neutron::core']){
    class {'mazut::neutron::core':}
  }
  exec { 'neutron-db-manage upgrade':
    command     => 'neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugin.ini upgrade head',
    path        => '/usr/bin',
    user        => 'neutron',
    logoutput   => 'on_failure',
    before      => Service['neutron-server'],
    require     => [Neutron_config['database/connection'], Neutron_config['DEFAULT/core_plugin']],
  }
  ->

  class { '::neutron::server':
    auth_host           => $controller_priv_host,
    auth_password       => $neutron_user_password,
    database_connection => $sql_connection,
  }

  if $admin_tenant_id {
    neutron_config {
      'DEFAULT/admin_tenant_id':      value  => $admin_tenant_id;
    }
  }

  if $neutron_core_plugin == 'neutron.plugins.ml2.plugin.Ml2Plugin' {
    class { '::neutron::plugins::ml2':
      type_drivers              => $ml2_type_drivers,
      tenant_network_types      => $ml2_tenant_network_types,
      mechanism_drivers         => $ml2_mechanism_drivers,
      flat_networks             => $ml2_flat_networks,
      network_vlan_ranges       => $ml2_network_vlan_ranges,
      tunnel_id_ranges          => $ml2_tunnel_id_ranges,
      vxlan_group               => $ml2_vxlan_group,
      vni_ranges                => $ml2_vni_ranges,
      enable_security_group     => str2bool_i("$ml2_security_group"),
      supported_pci_vendor_devs => $supported_pci_vendor_devs,
    }
    if 'opendaylight' in $ml2_mechanism_drivers {
      class { 'mazut::neutron::plugins::opendaylight':}
    }
    if 'telefonica' in $ml2_mechanism_drivers {
      class { 'mazut::neutron::plugins::telefonica':}
    }
    if $provision_neutron and ! $multiple_endpoints {
      class { 'mazut::neutron::provision':}
    }
  }

  if $neutron_core_plugin == 'neutron.plugins.nuage.plugin.NuagePlugin' {
    #neutron_config {
    #  'DEFAULT/service_plugins':          ensure => absent;
    #}
    class { 'mazut::neutron::plugins::nuage':}
  }
}
