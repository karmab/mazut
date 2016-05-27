# == Class: mazut::db::galera
#
#MySQL Galera Node
#
# === Hiera Parameters
#
# [*api_eth*]
#   (optional) Hostname or IP to bind MySQL daemon.
#   Defaults to '127.0.0.1'
#
# [*galera_master_name*]
#   (optional) Hostname or IP of the Galera master node, databases and users
#   resources are created on this node and propagated on the cluster.
#   Defaults to 'mgmt001'
#
# [*galera_internal_ips*]
#   (optional) Array of internal ip of the galera nodes.
#   Defaults to ['127.0.0.1']
#
# [*galera_gcache*]
#   (optional) Size of the Galera gcache
#   wsrep_provider_options, for master/slave mode
#   Defaults to '1G'
#
# [*mysql_root_password*]
#   (optional) The MySQL root password.
#   Puppet will attempt to set the root password and update `/root/.my.cnf` with it.
#   Defaults to 'rootpassword'
#
# [*mysql_sys_maint_password*]
#   (optional) The MySQL debian-sys-maint password.
#   Debian only parameter.
#   Defaults to 'sys_maint'
#
# [*galera_clustercheck_dbuser*]
#   (optional) The MySQL username for Galera cluster check (using monitoring database)
#   Defaults to 'clustercheck'
#
# [*galera_clustercheck_dbpassword*]
#   (optional) The MySQL password for Galera cluster check
#   Defaults to 'clustercheckpassword'
#
# [*galera_clustercheck_ipaddress*]
#   (optional) The name or ip address of host running monitoring database (clustercheck)
#   Defaults to '127.0.0.1'
#
# [*open_files_limit*]
#   (optional) An integer that specifies the open_files_limit for MySQL
#   Defaults to 65535
#
# [*max_connections*]
#   (optional) An integer that specifies the max_connections for MySQL
#   Defaults to 4096
#
# [*mysql_systemd_override_settings*]
#   (optional) An hash of setting to override for MariaDB unit file.
#   Defaults to {}
#   Example : { 'LimitNOFILE' => 'infinity', 'LimitNPROC' => 4, 'TimeoutSec' => '30' }
#
#
class mazut::db::galera (){
  $galera_master_name              = hiera('mazut::galera_master_name')
  $galera_internal_ips             = hiera('mazut::galera_internal_ips')
  $mysql_root_password             = hiera('mazut::root_db_password')
  $api_eth                         = '127.0.0.1'
  $galera_gcache                   = '1G'
  $mysql_sys_maint_password        = 'sys_maint'
  $galera_clustercheck_dbuser      = 'clustercheck'
  $galera_clustercheck_dbpassword  = 'clustercheckpassword'
  $galera_clustercheck_ipaddress   = '127.0.0.1'
  $open_files_limit                = 65535
  $max_connections                 = 4096
  $mysql_systemd_override_settings = {}
  $firewall_settings               = {}
  $mysql_server_package_name       = 'mariadb-galera-server'
  $mysql_client_package_name       = 'mariadb'
  $wsrep_provider                  = '/usr/lib64/galera/libgalera_smm.so'
  $mysql_server_config_file        = '/etc/my.cnf'
  $mysql_init_file                 = '/usr/lib/systemd/system/mariadb-bootstrap.service'
  $mysql_service_name              = 'mariadb'
  $dirs                            = [ '/var/run/mysqld', '/var/log/mysql' ]
  $mysql_config_file               = '/etc/my.cnf'

  include 'xinetd'
  if ! defined ( Package['rsync']) {
    package { 'rsync': ensure => installed }
  }

  $mysqld_options = {
    'mysqld' => {
      'skip-name-resolve'             => '1',
      'binlog_format'                 => 'ROW',
      'default-storage-engine'        => 'innodb',
      'innodb_autoinc_lock_mode'      => '2',
      'innodb_locks_unsafe_for_binlog'=> '1',
      'query_cache_size'              => '0',
      'query_cache_type'              => '0',
      'bind-address'                  => '0.0.0.0',
      'max_connections'               => '4096',
      'open_files_limit'              => '-1',
      'wsrep_provider'                => '/usr/lib64/galera/libgalera_smm.so',
      'wsrep_cluster_name'            => 'galera_cluster',
      'wsrep_slave_threads'           => '1',
      'wsrep_certify_nonPK'           => '1',
      'wsrep_max_ws_rows'             => '131072',
      'wsrep_max_ws_size'             => '1073741824',
      'wsrep_debug'                   => '0',
      'wsrep_convert_LOCK_to_trx'     => '0',
      'wsrep_retry_autocommit'        => '1',
      'wsrep_auto_increment_control'  => '1',
      'wsrep_drupal_282555_workaround'=> '0',
      'wsrep_causal_reads'            => '0',
      'wsrep_notify_cmd'              => '',
      'wsrep_sst_method'              => 'rsync',
    },
  }

  class { '::mysql::server':
    create_root_user        => false,
    create_root_my_cnf      => false,
    config_file             => $mysql_config_file,
    override_options        => $mysqld_options,
    package_name            => $mysql_server_package_name,
    service_manage          => false,
    service_enabled         => false,
  }

  file { '/etc/sysconfig/clustercheck' :
    ensure  => file,
    content => "MYSQL_USERNAME=root\nMYSQL_PASSWORD=''\nMYSQL_HOST=localhost\n",
  }

#  exec { 'galera-ready' :
#    command     => '/usr/bin/clustercheck >/dev/null',
#    timeout     => 30,
#    tries       => 180,
#    try_sleep   => 10,
#    environment => ['AVAILABLE_WHEN_READONLY=0'],
#    require     => [File['/etc/sysconfig/clustercheck'],Package[$mysql_server_package_name]],
#  }

  xinetd::service { 'galera-monitor' :
    port           => '9200',
    server         => '/usr/bin/clustercheck',
    per_source     => 'UNLIMITED',
    log_on_success => '',
    log_on_failure => 'HOST',
    flags          => 'REUSE',
    service_type   => 'UNLISTED',
    user           => 'root',
    group          => 'root',
    require     => [File['/etc/sysconfig/clustercheck'],Package[$mysql_server_package_name]],
  }
}
