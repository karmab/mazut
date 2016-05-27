class mazut::nova::resize () {
  $publickey  = hiera('mazut::nova_publickey')
  $privatekey = hiera('mazut::nova_privatekey')
  user {'nova': shell => '/bin/bash',}
  file { '/var/lib/nova/.ssh':
   ensure  => 'directory',
   owner   => 'nova',
   group   => 'nova',
   mode    => 700,
  }
  file { '/var/lib/nova/.ssh/config':
   ensure  => 'present',
   owner   => 'nova',
   group   => 'nova',
   mode    => 600,
   content => "Host *\nStrictHostKeyChecking no\nUserKnownHostsFile=/dev/null\n",
  }
  file {'/var/lib/nova/.ssh/id_rsa.pub':
   ensure  => 'present',
   content => "ssh-rsa $publickey\n",
   owner   => 'nova',
   group   => 'nova',
   mode    => 0644,
  }
  file { '/var/lib/nova/.ssh/id_rsa':
   ensure  => 'present',
   content => $privatekey,
   owner   => 'nova',
   group   => 'nova',
   mode    => 0600,
  }
  ssh_authorized_key { 'generic':
   user => 'nova',
   type => 'ssh-rsa',
   key  => $publickey,
  }
}
