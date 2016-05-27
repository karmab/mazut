# == Class: mazut::mongodb::replica
#
# A class to configure mongodb replicas
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
class mazut::mongodb::replica(){
  $replicaset   = hiera('mazut::mongodb_replicaset')
  $mongoservers = hiera('mazut::mongodb_servers')
  $bind_ip      = [$::ipaddress,'127.0.0.1']
  $port         = 27017
  $members      = suffix($mongoservers,":$port")
  $memberscount = count($members)

  #only create replsets when run from first node
  if $hostname =~ /^.*1/ and $memberscount > 1 {
    mongodb_replset { $replicaset:
      ensure  => present,
      members => $members,
      require => Class['::mongodb::server'],
   }    
 }
}
