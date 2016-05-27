# == Class: mazut::profiles::swiftstorage
#
# swift profile class
#
class mazut::profiles::swiftstorage () {
  class {'mazut::swift::storage':}
}
