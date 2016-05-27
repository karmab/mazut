# == Class: mazut::profiles::redis
#
# redis profile class
#
class mazut::profiles::redis (){
  $cluster  = hiera('mazut::cluster_redis')
  $service_manage = hiera('mazut::cluster_redis') ? { true  => false, false => true }
  class { '::redis' :
    service_manage => $service_manage,
    notify_service => $service_manage,
  }
  if $cluster {
    $cluster_master = hiera('mazut::cluster_master')
    if $::hostname == $cluster_master or $::fqdn == $cluster_master {
      pacemaker::resource::ocf { 'redis':
        ocf_agent_name  => 'heartbeat:redis',
        master_params   => '',
        meta_params     => 'notify=true ordered=true interleave=true',
        resource_params => 'wait_last_known_master=true',
        require         => Class['::redis'],
      } 
    }
  } 
}
