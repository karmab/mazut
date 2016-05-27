# haproxy
class mazut::roles::haproxy () {

  class {'mazut::profiles::haproxy':}
  ->
  class {'mazut::profiles::pacemaker':}
  ->
  class {'mazut::profiles::vips':}
}
