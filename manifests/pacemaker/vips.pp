class mazut::pacemaker::vips () {
    $vips = hiera('mazut::cluster_vips',{})
    define createvips($cidr){
      pacemaker::resource::ip { $name:
        ip_address   => $name,
        cidr_netmask => $cidr,
      } 
    }
    create_resources(createvips,$vips)
}
