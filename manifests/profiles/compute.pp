# == Class: mazut::profiles::compute
#
# compute profile class
#
class mazut::profiles::compute (){
  if ! defined(Class['mazut::neutron::core']){ 
  class {"mazut::neutron::core":}
  }
  class {"mazut::nova::compute":}
  class {"mazut::ceilometer::compute":}
}
