class mazut::cinder::backend::nfs(){
  $backend_nfs_name                 = hiera('mazut::cinder_backend_nfs_name')
  $nfs_shares                       = hiera('mazut::cinder_nfs_shares')
  $nfs_mount_options                = hiera('mazut::cinder_nfs_mount_options')

  cinder::backend::nfs { 'nfs':
    volume_backend_name => $backend_nfs_name,
    nfs_servers         => $nfs_shares,
    nfs_mount_options   => $nfs_mount_options,
    nfs_shares_config   => '/etc/cinder/shares-nfs.conf',
  }
}
