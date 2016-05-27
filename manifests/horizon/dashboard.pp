class mazut::horizon::dashboard {
  $secret_key             = hiera('mazut::horizon_secret_key')
  $allowed_hosts          = hiera('mazut::horizon_allowed_hosts')
  $api_version            = hiera('mazut::keystone_api_version')
  $debug                  = hiera('mazut::debug')
  $keystone_host          = hiera('mazut::controller_priv_host')
  $multiple_endpoints     = hiera('mazut::multiple_endpoints')
  $custom                 = hiera('mazut::horizon_custom')
  $cache_server_port      = '11211'
  $horizon_cert           = undef
  $horizon_key            = undef
  $horizon_ca             = undef
  $keystone_default_role  = '_member_'
  $memcached_servers      = undef
  $listen_ssl             = 'false'
  $endpoint_type          = 'internalURL'
  $version                = regsubst($api_version,'[vV](.*)','\1')
  $service_iface          = hiera('mazut::service_iface','eth0')
  $service_ip             = pick(get_ip_from_nic("$service_iface"),$::ipaddress)
  $extra_network_services = hiera('mazut::extra_network_services')
  $cache_server_ip        = hiera('mazut::horizon_hosts','127.0.0.1')
  $neutron_options        = {}
  if 'lbaas' in $extra_network_services {
    $neutron_options['enable_lb'] = true
  }
  if 'fwaas' in $extra_network_services {
    $neutron_options['enable_firewall'] = true
  }
  if 'vpnaas' in $extra_network_services {
    $neutron_options['enable_vpn'] = true
  }
  if 'dvr' in $extra_network_services {
    $neutron_options['enable_distributed_router'] = true
  }
  if 'harouter' in $extra_network_services {
    $neutron_options['enable_ha_router'] = true
  }
  if $horizon_custom {
    $local_settings_template = 'mazut/local_settings.py.erb'
  } else {
    $local_settings_template = 'horizon/local_settings.py.erb'
  }

  include ::memcached

  package {'python-memcached':
    ensure => installed,
  }~>
  package {'python-netaddr':
    ensure => installed,
    notify => Class['::horizon'],
  }

  file {'/etc/httpd/conf.d/rootredirect.conf':
    ensure  => present,
    content => 'RedirectMatch ^/$ /dashboard/',
    notify  => File['/etc/httpd/conf.d/openstack-dashboard.conf'],
  }

  if str2bool_i("$listen_ssl") {
    apache::listen { '443': }
  }

  # needed for https://bugzilla.redhat.com/show_bug.cgi?id=1111656
  class { '::apache':
    default_vhost => false,
  }
  
  if $multiple_endpoints {
    $endpoints         = hiera('mazut::endpoints')
    $available_regions = createregionslist($endpoints)
  } else {
    $available_regions = undef
  }

  class {'::horizon':
    bind_address            => $service_ip,
    cache_backend           => 'django.core.cache.backends.memcached.MemcachedCache',
    cache_server_ip         => $cache_server_ip,
    cache_server_port       => $cache_server_port,
    allowed_hosts           => $allowed_hosts,
    keystone_default_role   => $keystone_default_role,
    #keystone_host          => $keystone_host,
    keystone_url            => "http://${keystone_host}:5000/$api_version",
    horizon_cert            => $horizon_cert,
    horizon_key             => $horizon_key,
    local_settings_template => $local_settings_template,
    horizon_ca              => $horizon_ca,
    listen_ssl              => str2bool_i("$listen_ssl"),
    secret_key              => $horizon_secret_key,
    api_versions            => {'identity' => $version},
    openstack_endpoint_type => $endpoint_type,
    django_debug            => $debug,
    vhost_extra_params      => { setenvif => 'X-Forwarded-Proto https HTTPS=1' },
    available_regions       => $available_regions,
    neutron_options         => $neutron_options,
    django_session_engine   => 'django.contrib.sessions.backends.cache',
  }

# Concat::Fragment['Apache ports header'] ->
# File_line['ports_listen_on_bind_address_80']
# TODO: add a file_line to set array of memcached servers
# the above is an example of the required ordering

  if ($::selinux != "false"){
    selboolean { 'httpd_can_network_connect':
      value => on,
      persistent => true,
    }
  }

}
