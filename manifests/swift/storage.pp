class mazut::swift::storage () {
  $swift_storage_loopback         = hiera('mazut::swift_storage_loopback')
  $swift_storage_device           = hiera('mazut::swift_storage_device')
  $swift_storage_fstype           = hiera('mazut::swift_storage_fstype')
  $swift_ring_server              = hiera('mazut::swift_ringserver_ip')
  $swift_shared_secret            = hiera('mazut::swift_shared_secret')

  class { '::swift::storage::all':
    storage_local_net_ip  => '0.0.0.0',
    require               => Class['swift'],
    log_facility          => 'LOG_LOCAL1',
  }

  if(!defined(File['/srv/node'])) {
    file { '/srv/node':
      owner  => 'swift',
      group  => 'swift',
      ensure => directory,
      require => Package['openstack-swift'],
    }
  }

  swift::ringsync{["account","container","object"]:
      ring_server => $swift_ring_server,
      before => Class['swift::storage::all'],
      require => Class['swift'],
  }

  File <| |> -> Exec['restorecon']
  exec{'restorecon':
      path => '/sbin:/usr/sbin',
      command => 'restorecon -RvF /srv',
  }

  if ($::selinux != "false"){
      selboolean{'rsync_client':
          value => on,
          persistent => true,
      }
  }

  if str2bool_i("$swift_storage_loopback") {
    swift::storage::loopback { [$swift_storage_device]:
      base_dir     => '/srv/loopback-device',
      mnt_base_dir => '/srv/node',
      require      => Class['swift'],
      fstype       => $swift_storage_fstype,
      seek         => '1048576',
    }
  } elsif $swift_storage_fstype == 'xfs' {
    swift::storage::xfs { "$swift_storage_device":
      device => "/dev/$swift_storage_device",
    }
  } else  {
    swift::storage::ext4 { "$swift_storage_device":
      device => "/dev/$swift_storage_device",
    }
  }

  Class['swift'] -> Service <| |>
  if(!defined(Class['swift'])) {
    class { 'swift':
      swift_hash_suffix => $swift_shared_secret,
    }
  }
}
