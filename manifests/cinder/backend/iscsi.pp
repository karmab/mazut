class mazut::cinder::backend::iscsi(){
  $backend_iscsi_name               = hiera('mazut::cinder_backend_iscsi_name')
  $iscsi_bind_addr                  = hiera('mazut::cinder_iscsi_bind_addr')

  cinder::backend::iscsi { 'iscsi':
    volume_backend_name => $backend_iscsi_name,
    iscsi_ip_address    => $iscsi_bind_addr,
  }
}
