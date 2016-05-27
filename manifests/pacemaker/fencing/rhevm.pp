class mazut::pacemaker::fencing::rhevm () {
  $ipaddr          = hiera('mazut::rhevm_ipaddr')
  $login           = hiera('mazut::rhevm_login','admin@internal')
  $passwd          = hiera('mazut::rhevm_passwd')
  $hosts           = hiera('mazut::rhevm_hosts')
  define fence_rhevm($ipaddr,$login,$passwd) {
    pacemaker::stonith::fence_rhevm {$name:
      ipaddr         => $ipaddr,
      login          => $login,
      passwd         => $passwd,
      ssl            => true,
      ssl_insecure   => true,
      pcmk_host_list => $name,
    }
  }
  fence_rhevm { $hosts:
      ipaddr         => $ipaddr,
      login          => $login,
      passwd         => $passwd,
  }
}
