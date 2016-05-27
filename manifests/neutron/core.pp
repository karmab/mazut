class mazut::neutron::core (){
  $enable_agent                 = hiera('mazut::enable_agent')
  $neutron_core_plugin          = hiera('mazut::neutron_core_plugin')
  $auth_host                    = hiera('mazut::controller_priv_host')
  $nova_host                    = hiera('mazut::controller_priv_host')
  $enable_tunneling             = hiera('mazut::enable_tunneling')
  $mysql_host                   = hiera('mazut::mysql_host')
  $neutron_db_password          = hiera('mazut::neutron_db_password')
  $neutron_user_password        = hiera('mazut::neutron_user_password')
  $neutron_host                 = hiera('mazut::controller_priv_host')
  $nova_user_password           = hiera('mazut::nova_user_password')
  $amqp_port                    = hiera('mazut::amqp_port')
  $amqp_hosts                   = hiera('mazut::amqp_hosts')
  $amqp_username                = hiera('mazut::amqp_username')
  $amqp_password                = hiera('mazut::amqp_password')
  $tenant_network_type          = hiera('mazut::tenant_network_type')
  $debug                        = hiera('mazut::debug')
  $verbose                      = hiera('mazut::verbose')
  $private_iface                = hiera('mazut::private_iface')
  $private_ip                   = hiera('mazut::private_ip')
  $private_network              = hiera('mazut::private_network')
  $service_plugins              = hiera('mazut::service_plugins')
  $nova_url                     = undef
  $security_group_api           = 'neutron'
  $sql_connection               = "mysql://neutron:${neutron_db_password}@${mysql_host}/neutron"
  $rabbit_hosts                 = suffix($amqp_hosts,":$amqp_port")
  $service_iface                = hiera('mazut::service_iface','eth0')
  $service_ip                   = pick(get_ip_from_nic("$service_iface"),$::ipaddress)
  if $neutron_core_plugin == 'neutron.plugins.nuage.plugin.NuagePlugin' { 
    $neutron_ovs_bridge    = 'alubr0' 
    $final_service_plugins = delete($service_plugins,'router')
  } else { 
    $neutron_ovs_bridge    = 'br-int'
    $final_service_plugins = $service_plugins
  }

  class { '::neutron':
    enabled               => true,
    bind_host             => $service_ip,
    core_plugin           => $neutron_core_plugin,
    allow_overlapping_ips => true,
    rpc_backend           => 'rabbit',
    rabbit_hosts          => $rabbit_hosts,
    rabbit_port           => $amqp_port,
    rabbit_user           => $amqp_username,
    rabbit_password       => $amqp_password,
    debug                 => $debug,
    verbose               => $verbose,
    service_plugins       => $final_service_plugins,
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

  if $enable_agent {
   $agent_type = hiera('mazut::agent_type')
   class {"::mazut::neutron::agent::$agent_type":}
  }

  class { '::nova::network::neutron':
    neutron_admin_password => $neutron_user_password,
    neutron_url            => "http://${neutron_host}:9696",
    neutron_admin_auth_url => "http://${auth_host}:35357/v2.0",
    neutron_ovs_bridge     => $neutron_ovs_bridge,
    security_group_api     => $security_group_api,
  }
}
