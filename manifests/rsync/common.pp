class mazut::rsync::common ( ) {
  include ::xinetd

  package { 'rsync':
    ensure => installed,
  }

}
