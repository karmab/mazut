# == Class: mazut::db::services
class mazut::db::services (){
  $enable_galera                   = hiera('mazut::enable_galera')
  $keystone_db_host                = hiera('mazut::mysql_host')
  $keystone_db_password            = hiera('mazut::keystone_db_password')
  $cinder_db_password              = hiera('mazut::cinder_db_password')
  $glance_db_password              = hiera('mazut::glance_db_password')
  $heat_db_password                = hiera('mazut::heat_db_password')
  $nova_db_password                = hiera('mazut::nova_db_password')
  $neutron_db_password             = hiera('mazut::neutron_db_password')
  $trove_db_password               = hiera('mazut::trove_db_password')
  $designate_db_password           = hiera('mazut::designate_db_password')
  $sahara_db_password              = hiera('mazut::sahara_db_password')
  $mysql_root_password             = hiera('mazut::root_db_password')
  $keystone_db_user                = 'keystone'
  $glance_db_user                  = 'glance'
  $cinder_db_user                  = 'cinder'
  $neutron_db_user                 = 'neutron'
  $nova_db_user                    = 'nova'
  $heat_db_user                    = 'heat'
  $trove_db_user                   = 'trove'
  $sahara_db_user                  = 'sahara'
  $designate_db_user               = 'designate'
  $keystone_db_hosts               = ['127.0.0.1','%']
  $glance_db_hosts                 = ['127.0.0.1','%']
  $cinder_db_hosts                 = ['127.0.0.1','%']
  $neutron_db_hosts                = ['127.0.0.1','%']
  $nova_db_hosts                   = ['127.0.0.1','%']
  $heat_db_hosts                   = ['127.0.0.1','%']
  $trove_db_hosts                  = ['127.0.0.1','%']
  $sahara_db_hosts                 = ['127.0.0.1','%']
  $designate_db_hosts              = ['127.0.0.1','%']
  $cinder_db_host                  = $keystone_db_host
  $glance_db_host                  = $keystone_db_host
  $heat_db_host                    = $keystone_db_host
  $nova_db_host                    = $keystone_db_host
  $neutron_db_host                 = $keystone_db_host
  $trove_db_host                   = $keystone_db_host
  $sahara_db_host                  = $keystone_db_host
  $designate_db_host               = $keystone_db_host
  if ! $enable_galera {
    $keystone_db_allowed_hosts     = concat($keystone_db_hosts,$::fqdn)
    $glance_db_allowed_hosts       = concat($glance_db_hosts,$::fqdn)
    $cinder_db_allowed_hosts       = concat($cinder_db_hosts,$::fqdn)
    $neutron_db_allowed_hosts      = concat($neutron_db_hosts,$::fqdn)
    $nova_db_allowed_hosts         = concat($nova_db_hosts,$::fqdn)
    $heat_db_allowed_hosts         = concat($heat_db_hosts,$::fqdn)
    $trove_db_allowed_hosts        = concat($trove_db_hosts,$::fqdn)
    $sahara_db_allowed_hosts       = concat($sahara_db_hosts,$::fqdn)
    $designate_db_allowed_hosts    = concat($designate_db_hosts,$::fqdn)
  } else {
    $keystone_db_allowed_hosts     = $keystone_db_hosts
    $glance_db_allowed_hosts       = $glance_db_hosts
    $cinder_db_allowed_hosts       = $cinder_db_hosts 
    $neutron_db_allowed_hosts      = $neutron_db_hosts
    $nova_db_allowed_hosts         = $nova_db_hosts
    $heat_db_allowed_hosts         = $heat_db_hosts
    $trove_db_allowed_hosts        = $trove_db_hosts
    $sahara_db_allowed_hosts       = $sahara_db_hosts
    $designate_db_allowed_hosts    = $designate_db_hosts
  }

  # OpenStack DB
  class { 'keystone::db::mysql':
    dbname        => 'keystone',
    user          => $keystone_db_user,
    password      => $keystone_db_password,
    host          => $keystone_db_host,
    allowed_hosts => $keystone_db_allowed_hosts,
  }
  class { 'glance::db::mysql':
    dbname        => 'glance',
    user          => $glance_db_user,
    password      => $glance_db_password,
    host          => $glance_db_host,
    allowed_hosts => $glance_db_allowed_hosts,
  }
  class { 'nova::db::mysql':
    dbname        => 'nova',
    user          => $nova_db_user,
    password      => $nova_db_password,
    host          => $nova_db_host,
    allowed_hosts => $nova_db_allowed_hosts,
  }
  class { 'cinder::db::mysql':
    dbname        => 'cinder',
    user          => $cinder_db_user,
    password      => $cinder_db_password,
    host          => $cinder_db_host,
    allowed_hosts => $cinder_db_allowed_hosts,
  }
  class { 'neutron::db::mysql':
    dbname        => 'neutron',
    user          => $neutron_db_user,
    password      => $neutron_db_password,
    host          => $neutron_db_host,
    allowed_hosts => $neutron_db_allowed_hosts,
  }
  class { 'heat::db::mysql':
    dbname        => 'heat',
    user          => $heat_db_user,
    password      => $heat_db_password,
    host          => $heat_db_host,
    allowed_hosts => $heat_db_allowed_hosts,
  }
  class { 'trove::db::mysql':
    dbname        => 'trove',
    user          => $trove_db_user,
    password      => $trove_db_password,
    host          => $trove_db_host,
    allowed_hosts => $trove_db_allowed_hosts,
  }
  class { '::sahara::db::mysql':
    user          => $sahara_db_user,
    password      => $sahara_db_password,
    dbname        => $sahara_db_dbname,
    allowed_hosts => $sahara_db_allowed_hosts,
  }
  class { '::designate::db::mysql':
    user          => $designate_db_user,
    password      => $designate_db_password,
    dbname        => $designate_db_dbname,
    allowed_hosts => $designate_db_allowed_hosts,
  }
}
