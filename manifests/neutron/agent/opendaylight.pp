class mazut::neutron::agent::opendaylight (){
  $ohost = hiera('mazut::opendaylight_host')
  class {'vswitch::ovs':}
  ->
  exec {'configure_opendaylight':
   command => "ovs-vsctl set-manager tcp:${ohost}:6640",
   path    => '/usr/bin',
  }
}
