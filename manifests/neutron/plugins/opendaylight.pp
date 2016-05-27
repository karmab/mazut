class mazut::neutron::plugins::opendaylight () {
  $ohost              = hiera('mazut::opendaylight_host')
  $pport              = hiera('mazut::opendaylight_port')
  $ousername          = hiera('mazut::opendaylight_username')
  $opassword          = hiera('mazut::opendaylight_password')

  exec {"install_networkingodl":
    command => 'pip install networkingodl',
    path    => ['/usr/bin'],
  }->  
  neutron_plugin_ml2 {
    'ml2_odl/username':  value => $ousername;
    'ml2_odl/password':  value => $opassword;
    'ml2_odl/url'     :  value => "http://$ohost:$port/controller/nb/v2/neutron";
  }
}
