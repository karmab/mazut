class mazut::neutron::plugins::nuage () {
  $neutron_db_password  = hiera('mazut::neutron_db_password')
  $mysql_host           = hiera('mazut::mysql_host')
  $controller_priv_host = hiera('mazut::controller_priv_host')
  $keystone_api_version = hiera('mazut::keystone_api_version')
  $keystone_admin_token = hiera('mazut::keystone_admin_token')
  $net_partition        = hiera('mazut::net_partition')
  $vsdhostname          = hiera('mazut::vsdhostname')
  $vsdport              = hiera('mazut::vsdport')
  $vsdusername          = hiera('mazut::vsdusername')
  $vsdpassword          = hiera('mazut::vsdpassword')
  $nuage_api_version    = hiera('mazut::nuage_api_version')
  $nuage_cms_id         = hiera('mazut::nuage_cms_id',undef)

  package { ['nuage-openstack-neutron','nuage-openstack-neutronclient','nuage-openstack-heat','nuagenetlib'] : ensure => present}
  ->
  file {
  '/etc/neutron/plugins/nuage':
	ensure  => directory;
  '/etc/neutron/plugins/nuage/nuage_plugin.ini':
	ensure  => present,
  	content => template("mazut/nuage_plugin.ini.erb");
  '/etc/neutron/plugin.ini':
	ensure  => link,
	target  => '/etc/neutron/plugins/nuage/nuage_plugin.ini',
        require => File['/etc/neutron/plugins/nuage','/etc/neutron/plugins/nuage/nuage_plugin.ini'];
  }
}
