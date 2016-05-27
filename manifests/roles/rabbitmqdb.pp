# rabbit+db+pacemaker
class mazut::roles::rabbitmqdb() {
  class {'mazut::profiles::pacemaker':}
  ->
  class {'mazut::profiles::rabbitmq':}
  ->
  class {'mazut::profiles::db':}
  ->
  class {'mazut::profiles::vips':}
}
