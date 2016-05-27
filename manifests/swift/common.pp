class mazut::swift::common (){
  $swift_shared_secret = hiera('mazut::swift_shared_secret')

  #### Common ####
  #Class['swift'] -> Service <| |>
  if(!defined(Class['swift'])) {
    class { 'swift':
        swift_hash_suffix => $swift_shared_secret,
    }
  }
}
