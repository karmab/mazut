class mazut::haproxy::generic (){
  $openstack_config = {"keystone-admin"=>{"port"=>"35357"},"keystone"=>{"port"=>"5000"},"glance"=>{"port"=>"9292"},"cinder"=>{"port"=>"8776"},"neutron"=>{"port"=>"9696"},"nova"=>{"port"=>"8774"},"nova-metadata"=>{"port"=>"8775"},"vnc"=>{"port"=>"6080", "backend_mode"=>"http"},"ceilometer"=>{"port"=>"8777"},"heat-cfn"=>{"port"=>"8000"},"heat-api"=>{"port"=>"8004"},"sahara"=>{"port"=>"8386"},"swift"=>{"port"=>"8080"},"horizon"=>{"port"=>"80"}}
  $haproxyconfig  = hiera_hash('mazut::haproxy_config',$openstack_config)
  $service_manage = hiera('mazut::cluster_haproxy') ? { true  => false, false => true }

  define haproxyset($port,$frontend_mode='tcp',$backend_name=undef,$backend_mode=undef,$backend_port=undef,$balance='roundrobin',$backend_options=['tcplog'],$servers=hiera('mazut::haproxy_servers'),$reqadd=undef,$acl=undef,$sslcert=undef) {
    $vip               = hiera('mazut::haproxy_vip')
    if $backend_name {
      $frontend_settings = { 'default_backend' => "${backend_name}" }
    } else {
      $frontend_settings = { 'default_backend' => "${name}_backend" }
    }
    $backend_settings  = { 'option' => $backend_options, 'balance' => $balance }
    if $backend_port {
      $backend_real_port = $backend_port
    } else {
      $backend_real_port = $port
    }
    if $reqadd {
      $backend_settings['reqadd'] = $reqadd
    }
    if $backend_mode {
      $backend_settings['mode'] = $backend_mode
    }
    if $acl {
      $frontend_settings['acl']         = createacl($acl)
      $frontend_settings['use_backend'] = createaclrules($acl)
    }
    if $sslcert{
      $bind_options = ['ssl','crt', $sslcert]
    } else{
      $bind_options = []
    }
    $bind = {"${vip}:${port}" => $bind_options}
    haproxy::frontend { $name:
      bind          => $bind,
      mode          => $frontend_mode,
      bind_options  => 'accept-proxy',
      options       => $frontend_settings,
    }
    if ! $backend_name {
      haproxy::backend { "${name}_backend":
        options => $backend_settings,
      }
      haproxy::balancermember { "${name}_backend_members":
        listening_service => "${name}_backend",
        ports             => $backend_real_port,
        server_names      => $servers,
        ipaddresses       => $servers,
        options           => 'check inter 1s',
      }
    }
  }
 
  if $::selinux {
     selboolean{'haproxy_connect_any':
       value => on,
       persistent => true,
     }
  }
  sysctl::value { "net.ipv4.ip_nonlocal_bind":  value => "1"}
  ->
  class { '::haproxy':
    service_manage   => $service_manage,
    defaults_options => {
      'mode'    => 'http',
      'option'  => 'redispatch',
      'retries' => '3',
      'timeout' => [
        'connect 5s',
        'client 30s',
        'server 30s',
      ],
      'maxconn' => '15000',
    },
  }
  create_resources ( haproxyset, $haproxyconfig )
}
