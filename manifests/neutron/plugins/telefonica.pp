class mazut::neutron::plugins::telefonica () {
  $server                    = hiera('mazut::telefonica_server')
  $port                      = hiera('mazut::telefonica_port')
  $switch_file               = hiera('mazut::telefonica_switch_file')
  $supported_pci_vendor_devs = hiera('mazut::pci_vendor_devs')

  neutron_plugin_ml2 {
    'ml2_telefonica/server':                    value => $server;
    'ml2_telefonica/port':                      value => $port;
    'ml2_telefonica/switch_connections.yaml':   value => $switch_file;
    'ml2_sriov/supported_pci_vendor_devs':      value => $supported_pci_vendor_devs;
  }
}
