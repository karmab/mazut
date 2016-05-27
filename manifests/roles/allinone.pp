# allinone
class mazut::roles::allinone () {

  class {'mazut::profiles::db':}
  ->
  class {'mazut::profiles::rabbitmq':}
  ->
  class {'mazut::profiles::mongodb':}
  ->
  class {'mazut::profiles::redis':}
  ->
  class {'mazut::profiles::api':}
  ->
  class {'mazut::profiles::networker':}
  ->
  class {'mazut::profiles::compute':}
  ->
  class {'mazut::profiles::swiftstorage':}
  ->
  class {'mazut::profiles::horizon':}
}
