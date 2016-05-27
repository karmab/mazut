# == Class: mazut::mongodb::core
#
# A class to configure core mongodb
#
# === Hiera Parameters
# [*replicaset*]
#   ReplicaSet name
#   Defaults to 'replica'
#
# [*mongoservers*]
#   List of mongo servers
#
#
class mazut::mongodb::core(){
  $set_replica    = hiera('mazut::mongodb_replica')
  $bind_ip        = [$::ipaddress,'127.0.0.1']
  $port           = 27017
  $service_manage = hiera('mazut::cluster_mongodb') ? { true  => false, false => true }
  if $set_replica {
    $replicaset   = hiera('mazut::mongodb_replicaset')
  }else {
    $replicaset   = undef
  }
  class{'::mongodb::client':} ->
  class{ '::mongodb::server':
    ensure         => present,
    bind_ip        => $bind_ip,
    port           => $port,
    replset        => $replicaset,
    service_manage => $service_manage,
  }
}
