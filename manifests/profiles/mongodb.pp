# == Class: mazut::profiles::mongodb
#
# mongodb profile class
#
class mazut::profiles::mongodb(){
  $cluster  = hiera('mazut::cluster_mongodb')
  $replica = hiera('mazut::mongodb_replica')
  class{'::mazut::mongodb::core':}
  if $cluster {
    $cluster_master = hiera('mazut::cluster_master')
    if $::hostname == $cluster_master or $::fqdn == $cluster_master {
      pacemaker::resource::service { 'mongod':
        op_params    => 'start timeout=120s stop timeout=100s',
        clone_params => true,
        require      => Class['mazut::mongodb::core'],
      }
    }
  }
  if $replica {
    class{'::mazut::mongodb::replica':}
  }
}
