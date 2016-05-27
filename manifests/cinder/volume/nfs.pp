class mazut::cinder::volume::nfs {
  $nfs_shares                       = hiera('mazut::cinder_nfs_shares')
  $nfs_mount_options                = hiera('mazut::cinder_nfs_mount_options')

  if ! defined(Package['nfs-utils']) {
    package { 'nfs-utils':
      ensure => 'present',
    }
  }

  if ($::selinux != "false") and ! defined(Selboolean['virt_use_nfs']){
    selboolean { 'virt_use_nfs':
        value => on,
        persistent => true,
    } -> Package['nfs-utils']
  }
  Package['nfs-utils'] -> Cinder::Backend::Nfs<| |>

  class { '::cinder::volume::nfs':
    nfs_servers       => $nfs_shares,
    nfs_mount_options => $nfs_mount_options,
    nfs_shares_config => '/etc/cinder/shares-nfs.conf',
  }

}
