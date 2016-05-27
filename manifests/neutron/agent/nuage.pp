class mazut::neutron::agent::nuage (){
  $activecontroller     = hiera('mazut::nuage_activecontroller') 
  $standbycontroller    = hiera('mazut::nuage_standbycontroller')
  $novaip               = hiera('mazut::controller_priv_ip')
  $metadatasecret       = hiera('mazut::neutron_metadata_proxy_secret')
  $novapassword         = hiera('mazut::admin_password')
  $keystoneip           = hiera('mazut::controller_priv_host')
  $keystone_api_version = hiera('mazut::keystone_api_version')
  $defaultbridge        = 'alubr0'
  $connectiontype       = 'tcp'
  $agentport	        = 9697
  $metadataport         = 8775
  $novausername         = 'admin'

  package { ['openstack-neutron-openvswitch','openvswitch'] : ensure => absent }
  ->
  package { ['python-novaclient','nuage-openvswitch','nuage-metadata-agent'] : ensure => present }
  ->
  file {
   '/etc/default/openvswitch':
   ensure  => present,
   content => template('mazut/openvswitch.erb'); 
   '/etc/default/nuage-metadata-agent':
   ensure  => present,
   content => template('mazut/nuage-metadata-agent.erb'); 
       }
  ->
  service {'openvswitch':
   ensure     => running,
   enable     => true,
   hasrestart => true,
   subscribe  => File['/etc/default/openvswitch','/etc/default/nuage-metadata-agent'];
         }
  ->
  exec {"nuage_fix":
   command => "service openvswitch restart",
   path    => "$::path",
   unless  => "ovs-vsctl show | grep -q $activecontroller";
       }
}
