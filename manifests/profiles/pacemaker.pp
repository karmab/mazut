# == Class: mazut::profiles::pacemaker
#
# pacemaker profile class
#
class mazut::profiles::pacemaker() {
  class {'mazut::pacemaker::core':}
}
