class mazut::nova::compute (){
  $auth_host                    = hiera('mazut::controller_priv_host')
  $glance_host                  = hiera('mazut::controller_priv_host')
  $nova_host                    = hiera('mazut::controller_priv_host')
  $mysql_host                   = hiera('mazut::mysql_host')
  $nova_db_password             = hiera('mazut::nova_db_password')
  $nova_user_password           = hiera('mazut::nova_user_password')
  $tenant_network_type          = hiera('mazut::tenant_network_type')
  $private_iface                = hiera('mazut::private_iface')
  $private_ip                   = hiera('mazut::private_ip')
  $private_network              = hiera('mazut::private_network')
  $service_iface                = hiera('mazut::service_iface','eth0')
  $nfv                          = hiera('mazut::enable_nfv')
  $resize                       = hiera('mazut::enable_resize')
  $service_ip                   = pick(get_ip_from_nic("$service_iface"),$::ipaddress)
  $pci_passthrough              = $nfv ? { false => undef , true => hiera('mazut::pci_passthrough') }

  if ! defined(Nova_config['cinder/catalog_info']) {
    nova_config {
      'cinder/catalog_info':      value => 'volumev2:cinderv2:internalURL';
    }
  }

  if !empty($private_ip) {
      nova_config {
          'DEFAULT/my_ip':      value => $private_ip;
      }
  }

  if ! defined(Class['mazut::nova::core']){
    class {'mazut::nova::core':}  
  }
  if str2bool_i($::kvm_capable) {
    $libvirt_type = 'kvm'
  } else {
    include mazut::nova::qemu
    $libvirt_type = 'qemu'
  }

  class { '::nova::compute::libvirt':
    libvirt_virt_type => $libvirt_type,
    vncserver_listen  => $service_ip,
    #vncserver_listen  => '0.0.0.0',
  }

   $compute_ip = find_ip("$private_network",
                         "$private_iface",
                        "$private_ip")
  class { '::nova::compute':
    enabled                       => true,
    instance_usage_audit          => true,
    instance_usage_audit_period   => 'hour',
    vncserver_proxyclient_address => $compute_ip,
    pci_passthrough               => $pci_passthrough,
  }

  include mazut::tuned::virtual_host
  if $resize {
    class {'mazut::nova::resize':}  
  }

  if $nfv {
    nova_config { 'DEFAULT/vcpu_pin_set': value => $::isolcpus, }
  }
}
