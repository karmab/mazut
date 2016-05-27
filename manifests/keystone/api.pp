class mazut::keystone::api () {
  $admin_user                    = hiera('mazut::admin_user','admin')
  $admin_email                   = hiera('mazut::admin_email')
  $admin_password                = hiera('mazut::admin_password')
  $controller_admin_host         = hiera('mazut::controller_admin_host')
  $controller_priv_host          = hiera('mazut::controller_priv_host')
  $controller_pub_host           = hiera('mazut::controller_pub_host')
  $keystone_admin_token          = hiera('mazut::keystone_admin_token')
  $keystone_api_version          = hiera('mazut::keystone_api_version')
  $keystone_db_password          = hiera('mazut::keystone_db_password')
  $keystonerc                    = hiera('mazut::keystonerc')
  $mysql_host                    = hiera('mazut::mysql_host')
  $mysql_root_password           = hiera('mazut::mysql_root_password')
  $amqp_port                     = hiera('mazut::amqp_port')
  $amqp_hosts                    = hiera('mazut::amqp_hosts')
  $amqp_username                 = hiera('mazut::amqp_username')
  $amqp_password                 = hiera('mazut::amqp_password')
  $debug                         = hiera('mazut::debug')
  $verbose                       = hiera('mazut::verbose')
  $token_format                  = hiera('mazut::token_format')
  $region                        = hiera('mazut::region')
  $public_url                    = hiera('mazut::public_url_keystone')
  $provision_keystone            = hiera('mazut::provision_keystone')
  $provision_tenant              = hiera('mazut::provision_tenant')
  $provision_user                = hiera('mazut::provision_user')
  $provision_password            = hiera('mazut::provision_password')
  $ldap                          = hiera('mazut::enable_ldap')
  $admin_url                     = "http://$controller_admin_host:35357"
  $internal_url                  = "http://$controller_priv_host:5000"
  $url                           = pick($public_url,"http://$controller_priv_host:5000")
  $public                        = "$url"
  $rabbit_hosts                  = suffix($amqp_hosts,":$amqp_port")
  $service_iface                 = hiera('mazut::service_iface','eth0')
  $service_ip                    = pick(get_ip_from_nic("$service_iface"),$::ipaddress)
  $final_password                = $ldap ? { false  => $admin_password, true => undef }
  $configure_user                = $ldap ? { false  => true, true => false }

  $nova_sql_connection = "mysql://nova:${nova_db_password}@${mysql_host}/nova"

  class {'::mazut::keystone::base':}->
  class {'::keystone':
    token_provider          => $token_format,
    admin_token             => $keystone_admin_token,
    database_connection     => "mysql://keystone:${keystone_db_password}@${mysql_host}/keystone",
    verbose                 => $verbose,
    debug                   => $debug,
    rabbit_hosts            => $rabbit_hosts,
    rabbit_userid           => $amqp_username,
    rabbit_password         => $amqp_password,
    public_bind_host        => $service_ip,
    admin_bind_host         => $service_ip,
    public_endpoint         => $url,
  }

  class { 'keystone::roles::admin':
    admin               => $admin_user,
    email               => $admin_email,
    password            => $final_password,
    admin_tenant        => 'admin',
    configure_user      => $configure_user,
    configure_user_role => false,
  }
  class { 'keystone::endpoint':
    public_url   => $public,
    admin_url    => $admin_url,
    internal_url => $internal_url, 
    region       => $region,
    version      => $keystone_api_version,
  }

  #Keystonerc
  if str2bool_i("$keystonerc") {
    class { 'mazut::keystone::client':}
  }

  # Needed roles 
  keystone_role { ['heat_stack_owner','heat_stack_user','SwiftOperator']:
    ensure => present,
  }->
  keystone_user_role { "$admin_user@admin":
    roles => ['admin', 'heat_stack_owner']
  }

  file { '/etc/keystone/ssl':
    ensure  => directory,
    source  => 'puppet:///modules/mazut/keystone/ssl',
    recurse => true,
    purge   => true,
    owner   => 'keystone',
    group   => 'keystone',
    notify  => Service['keystone'],
  }
  cron {'token_flush':
    ensure    => present,
    command   => '/usr/bin/keystone-manage token_flush',
    user      => root,
    hour      => 00,
    minute    => 00,
    require   => Package['keystone'],
  }  

  if $provision_keystone and ! $ldap {
    keystone_tenant { $provision_tenant:
      ensure           => present,
      description      => 'Tenant provisioned through puppet'
    }
    keystone_user { $provision_user:
      ensure   => present,
      enabled  => true,
      password => $provision_password, 
    }->
    keystone_user_role { "${provision_user}@${provision_tenant}":
      ensure => present,
      roles  => ['admin'],
    }
  }
  if $ldap {
    class {'mazut::keystone::ldap':} 
  }

}
