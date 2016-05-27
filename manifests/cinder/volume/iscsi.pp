class mazut::cinder::volume::iscsi (){
  $iscsi_bind_addr = hiera('mazut::iscsi_bind_addr')
  class { '::cinder::volume::iscsi':
    iscsi_ip_address => $iscsi_bind_addr,
  }
}
