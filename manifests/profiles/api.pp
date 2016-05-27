# == Class: mazut::profiles::api
#
# api profile class
#
class mazut::profiles::api () {
  $extra_services = hiera('mazut::extra_services')
  #Core services 
  class {'mazut::keystone::api':}
  class {'mazut::glance::api':}
  class {'mazut::cinder::api':}
  class {'mazut::cinder::volume':}
  class { "mazut::neutron::api": }
  class {'mazut::nova::api':}
  class {'mazut::heat::api':}
  #Extra services
  $apilist = suffix(prefix($extra_services,'mazut::'),'::api')
  class{$apilist:}		
}
