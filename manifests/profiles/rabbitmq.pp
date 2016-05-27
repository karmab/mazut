# == Class: mazut::profiles::rabbitmq
#
# rabbitmq profile class
#
class mazut::profiles::rabbitmq(){
  $username                 = hiera('mazut::amqp_username')
  $password                 = hiera('mazut::amqp_password')
  $cluster_nodes            = hiera('mazut::amqp_hosts')
  $cookie                   = hiera('mazut::amqp_cookie')
  $cluster                  = hiera('mazut::cluster_rabbitmq')
  $service_manage           = hiera('mazut::cluster_rabbitmq') ? { true  => false, false => true }

  class { "::rabbitmq":
    environment_variables    => { },
    wipe_db_on_cookie_change => true,
    config_cluster           => true,
    erlang_cookie            => $cookie,
    cluster_nodes            => $cluster_nodes,
    default_user             => $username,
    default_pass             => $password,
    admin_enable             => true,
    package_provider         => "yum",
    manage_repos             => false,
    service_manage           => $service_manage
  }

  if $cluster {
    $cluster_master = hiera('mazut::cluster_master')
    if $::hostname == $cluster_master or $::fqdn == $cluster_master {
      pacemaker::resource::ocf { 'rabbitmq':
      ocf_agent_name  => 'heartbeat:rabbitmq-cluster',
      resource_params => 'set_policy=\'ha-all ^(?!amq\.).* {"ha-mode":"all"}\'',
      clone_params    => 'ordered=true interleave=true',
      require         => Class['::rabbitmq'],
      }
    }
  } else {
    rabbitmq_policy { 'ha-all@/':
      pattern    => "^(?!amq\.).*",
      definition => {
        'ha-mode' => 'all',
      },
   }
  }
}
