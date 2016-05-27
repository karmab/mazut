class mazut::cinder::volume::netapp (){
  $netapp_ip               = hiera('mazut::netapp_ip')
  $netapp_port             = hiera('mazut::netapp_port')
  $netapp_login            = hiera('mazut::netapp_login')         
  $netapp_password         = hiera('mazut::netapp_password')
  $netapp_storage_family   = hiera('mazut::netapp_storage_family')
  $netapp_storage_protocol = hiera('mazut::netapp_storage_protocol')
  $netapp_shares           = hiera('mazut::netapp_shares')
  $netapp_shares_config    = '/etc/cinder/nfs_shares'
  $netapp_vserver          = hiera('mazut::netapp_vserver')
  $volume_driver           = 'cinder.volume.drivers.netapp.common.NetAppDriver'

  file {$netapp_shares_config:
    content => join($netapp_shares, "\n"),
    require => Package['cinder'],
    notify  => Service['cinder-volume']
  }

  cinder_config {
    ##"DEFAULT/enabled_backends":                    value => $netapp_mode;
    'netapp/volume_driver':                value => $volume_driver;
    'netapp/netapp_login':                 value => $netapp_login;
    'netapp/netapp_password':              value => $netapp_password; #secret => true;
    'netapp/netapp_server_hostname':       value => $netapp_ip;
    'netapp/netapp_server_port':           value => $netapp_port;
    'netapp/netapp_storage_family':        value => $netapp_storage_family;
    'netapp/netapp_storage_protocol':      value => $netapp_storage_protocol;
    'netapp/nfs_shares_config':            value => $netapp_shares_config;
    'netapp/netapp_vserver':               value => $netapp_vserver;
  }
}
