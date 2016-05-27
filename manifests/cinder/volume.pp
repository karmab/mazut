class mazut::cinder::volume(){
  $backend_iscsi                    = hiera('mazut::cinder_backend_iscsi')
  $backend_netapp                   = hiera('mazut::cinder_backend_netapp')
  $backend_nfs                      = hiera('mazut::cinder_backend_nfs')
  $backend_rbd                      = hiera('mazut::cinder_backend_rbd')
  $multiple_backends                = hiera('mazut::cinder_multiple_backends')

  class { '::cinder::volume': }

  if str2bool_i("$backend_rbd") {
    cinder_config {
      'DEFAULT/glance_api_version':         value => '2',
    }
  }

  if !str2bool_i("$multiple_backends") {

    # single backend
    # ensure multiple backends config option is empty
    if str2bool_i("$backend_netapp") {
      class { '::cinder::backends':
        enabled_backends => ['netapp'],
      }
    }else {
      class { '::cinder::backends':
        enabled_backends => [],
      }
    }

    if str2bool_i("$backend_nfs") {
      #include ::mazut::cinder::volume::nfs
      class { '::mazut::cinder::volume::nfs':}
    } elsif str2bool_i("$backend_netapp") {
      $netapp_backends = ['netapp']
      class { '::mazut::cinder::volume::netapp':}
    } elsif str2bool_i("$backend_rbd") {
      class { '::mazut::cinder::volume::rbd':}
    } elsif str2bool_i("$backend_iscsi") {
      class { '::mazut::cinder::volume::iscsi':}
    } else {
      fail("Enable a backend for cinder-volume.")
    }
  } else {

    # multiple backends
    if str2bool_i("$backend_nfs") {
      #include ::mazut::cinder::backend::nfs
      $nfs_backends = ["nfs"]
      class {'::mazut::cinder::backend::nfs':}
    }
    if str2bool_i("$backend_rbd") {
      $rbd_backends = ["rbd"]
      class {'::mazut::cinder::backend::rbd':}
    }
    if str2bool_i("$backend_iscsi") {
      $iscsi_backends = ["iscsi"]
      class {'::mazut::cinder::backend::iscsi':}
    }

    $enabled_backends = join_arrays_if_exist(
      'nfs_backends',
      'netapp_backends',
      'rbd_backends',
      'iscsi_backends')
    if $enabled_backends == [] {
      fail("Enable at least one backend for cinder-volume.")
    }

    # enable the backends
    class { '::cinder::backends':
      enabled_backends => $enabled_backends,
    }
  }
}
