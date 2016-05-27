# == Class: mazut::db::single
#
#MySQL Single Node
#
# === Hiera Parameters
#
# [*api_eth*]
#   (optional) Hostname or IP to bind MySQL daemon.
#   Defaults to '127.0.0.1'
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
class mazut::db::single (){
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
  $mysql_server_package_name       = 'mariadb-server'
  $mysql_client_package_name       = 'mariadb'
  $mysql_server_config_file        = '/etc/my.cnf'
  $mysql_service_name              = 'mariadb'

  if $mysql_systemd_override_settings['LimitNOFILE'] {
    $open_files_limit_real = $mysql_systemd_override_settings['LimitNOFILE']
    $mysql_systemd_override_settings_real = $mysql_systemd_override_settings
  } else {
    $open_files_limit_real = $open_files_limit
    $mysql_systemd_override_settings_real = merge($mysql_systemd_override_settings, { 'LimitNOFILE' => $open_files_limit})
  }

  class { 'mysql::server':
    manage_config_file => false,
    config_file        => $mysql_server_config_file,
    package_name       => $mysql_server_package_name,
    service_name       => $mysql_service_name,
    create_root_my_cnf => true,
    override_options   => {
      'mysqld' => {
        'bind-address' => $api_eth
      }
    },
    root_password      => $mysql_root_password,
  }

  class { 'mysql::client':
    package_name => $mysql_client_package_name,
  }

  class { 'mazut::db::services':}
}
