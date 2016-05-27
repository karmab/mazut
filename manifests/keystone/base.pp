class mazut::keystone::base () {

  if (str2bool($::selinux) ) {
    package{ 'openstack-selinux': ensure => present, }
  }
  service { "auditd":
    ensure => "running",
    enable => true,
  }
  if ! defined( Class['memcached']) {
   include ::memcached
  }
}
