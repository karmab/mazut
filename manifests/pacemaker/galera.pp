class mazut::pacemaker::galera (){
  $galera_internal_ips = hiera('mazut::galera_internal_ips')
  $nodes               = join($galera_internal_ips,',') 
  $nodes_number        = count($galera_internal_ips) 

  pacemaker::resource::ocf { 'galera' :
     ocf_agent_name  => 'heartbeat:galera',
     op_params       => 'promote timeout=300s on-fail=block',
     master_params   => '',
     meta_params     => "master-max=$nodes_number ordered=true",
     resource_params => "additional_parameters='--open-files-limit=16384' enable_creation=true wsrep_cluster_address='gcomm://${nodes}'",
     require         => Class['::mysql::server'],
     #before          => Exec['galera-ready'],
  } 

}
