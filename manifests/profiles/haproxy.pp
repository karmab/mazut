# == Class: mazut::profiles::haproxy
#
# haproxy profile class
#
class mazut::profiles::haproxy (){
  $cluster  = hiera('mazut::cluster_haproxy')
  class {'mazut::haproxy::generic':}
  if $cluster {
    $cluster_master = hiera('mazut::cluster_master')
    if $::hostname == $cluster_master or $::fqdn == $cluster_master {
      pacemaker::resource::service { 'haproxy':
        clone_params => true,
      } 
    }
  } 
}
