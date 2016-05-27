class mazut::cinder::volume::rbd (){
  $rbd_pool                         = hiera('mazut::cinder_rbd_pool')
  $rbd_ceph_conf                    = hiera('mazut::cinder_rbd_ceph_conf')
  $rbd_flatten_volume_from_snapshot = hiera('mazut::cinder_rbd_flatten_volume_from_snapshot')
  $rbd_max_clone_depth              = hiera('mazut::cinder_rbd_max_clone_depth')
  $rbd_user                         = hiera('mazut::cinder_rbd_user')
  $rbd_secret_uuid                  = hiera('mazut::cinder_rbd_secret_uuid')

  class { '::cinder::volume::rbd':
    rbd_pool            => $rbd_pool,
    rbd_ceph_conf       => $rbd_ceph_conf,
    rbd_flatten_volume_from_snapshot
                        => $rbd_flatten_volume_from_snapshot,
    rbd_max_clone_depth => $rbd_max_clone_depth,
    rbd_user            => $rbd_user,
    rbd_secret_uuid     => $rbd_secret_uuid,
  }
}
