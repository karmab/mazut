class mazut::pacemaker::core () {
  $cluster_members      = hiera('mazut::cluster_members')
  $stonith              = hiera('mazut::stonith')
  $transport            = hiera('mazut::cluster_transport')
  $settle_timeout       = '20'
  $settle_tries         = '3'
  $settle_try_sleep     = '10'

  class {'pacemaker::corosync':
    cluster_name         => 'openstack',
    cluster_members      => join($cluster_members,' '),
    manage_fw            => false,
    setup_cluster        => true,
    settle_timeout       => $settle_timeout,
    settle_tries         => $settle_tries,
    settle_try_sleep     => $settle_try_sleep,
    cluster_setup_extras => { '--transport' => $transport},
  }

  if $stonith {
    $stonith_type = hiera('mazut::stonith_type')
    class {'pacemaker::stonith': disable => false }
    class {"mazut::pacemaker::fencing::$stonith_type":}
  }else{
    class {'pacemaker::stonith': disable => true }
  }

  Class['pacemaker::corosync'] -> Class['pacemaker::stonith']
}
