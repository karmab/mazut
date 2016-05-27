class mazut::nova::core (){
  $glance_host                  = hiera('mazut::controller_priv_host')
  $mysql_host                   = hiera('mazut::mysql_host')
  $nova_db_password             = hiera('mazut::nova_db_password')
  $nova_user_password           = hiera('mazut::nova_user_password')
  $amqp_port                    = hiera('mazut::amqp_port')
  $amqp_hosts                   = hiera('mazut::amqp_hosts')
  $amqp_username                = hiera('mazut::amqp_username')
  $amqp_password                = hiera('mazut::amqp_password')
  $debug                        = hiera('mazut::debug')
  $verbose                      = hiera('mazut::verbose')
  $controller_priv_hosts        = hiera('mazut::memcached_servers',false)
  $public_url_novnc             = hiera('mazut::public_url_novnc')
  $vncproxy_common              = hiera('nova::vncproxy::common::vncproxy_host',true)
  $rabbit_hosts                 = suffix($amqp_hosts,":$amqp_port")
  if $controller_priv_hosts {
    $memcached_servers            = suffix($controller_priv_hosts,":11211")
  } else {
    $memcached_servers            = false
  }

  #sysctl rabbitmq stuff 
  sysctl::value { "net.ipv4.tcp_keepalive_intvl":  value => "1"}
  sysctl::value { "net.ipv4.tcp_keepalive_probes": value => "5"}
  sysctl::value { "net.ipv4.tcp_keepalive_time":   value => "5"}

  if str2bool($::selinux) and ! defined(Package['openstack-selinux']) {
    package{ 'openstack-selinux': ensure => present, }
  }

  if ! defined(Package['nfs-utils']){

    package { 'nfs-utils': ensure => 'present',}
    service { 'rpcbind': ensure => 'running',}

    if ($::selinux != "false") and ! defined(Selboolean['virt_use_nfs']){
      selboolean{'virt_use_nfs':
          value => on,
          persistent => true,
      }
    }
  }

  $nova_sql_connection = "mysql://nova:${nova_db_password}@${mysql_host}/nova"

  class { '::nova':
    database_connection     => $nova_sql_connection,
    image_service      => 'nova.image.glance.GlanceImageService',
    glance_api_servers => "$glance_host:9292",
    rpc_backend        => 'nova.openstack.common.rpc.impl_kombu',
    rabbit_hosts       => $rabbit_hosts,
    rabbit_port        => $amqp_port,
    rabbit_userid      => $amqp_username,
    rabbit_password    => $amqp_password,
    verbose            => $verbose,
    debug              => $debug,
    memcached_servers  => $memcached_servers,
  }

  if $public_url_novnc != '' and ! $vncproxy_common {
    nova_config {
      'DEFAULT/novncproxy_base_url': value => $public_url_novnc;
    }
  }

}
