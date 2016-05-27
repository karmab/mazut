class mazut::tuned::virtual_host {

  package {'tuned':
    ensure => present,
  }
  service {'tuned':
    ensure  => running,
    require => Package['tuned'],
  }
  exec {'tuned-virtual-host':
    unless  => '/usr/sbin/tuned-adm active | /bin/grep virtual-host',
    command => '/usr/sbin/tuned-adm profile virtual-host',
    require => Service['tuned'],
    subscribe => Service['tuned'],
  }
}
