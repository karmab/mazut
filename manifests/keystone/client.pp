class mazut::keystone::client(){
  $admin_user                    = hiera('mazut::admin_user','admin')
  $admin_password                = hiera('mazut::admin_password')
  $keystone_api_version          = hiera('mazut::keystone_api_version')
  $controller_admin_host         = hiera('mazut::controller_admin_host')
  $provision_keystone            = hiera('mazut::provision_keystone')
  $provision_tenant              = hiera('mazut::provision_tenant')
  $provision_user                = hiera('mazut::provision_user')
  $provision_password            = hiera('mazut::provision_password')
  $region                        = hiera('mazut::region')

  define openstack_client_pkgs() {
    if ! defined(Package[$name]) {
      package { $name: ensure => 'installed' }
    }
  }
  
  case $keystone_api_version {
  'v2.0'   : { $version = '2.0' } 
  'v3'     : { $version = '3' } 
  default  : { $version = '2.0' } 
 } 
    

  $clientdeps = ["python-iso8601"]
  $clientlibs = [ "python-novaclient", 
                  "python-keystoneclient", 
                  "python-glanceclient", 
                  "python-cinderclient", 
                  "python-neutronclient", 
                  "python-swiftclient", 
                  "python-heatclient" ]

  openstack_client_pkgs { $clientdeps: }
  openstack_client_pkgs { $clientlibs: }

  $rcadmin_content = "export OS_USERNAME=$admin_user
export OS_TENANT_NAME=admin   
export OS_PASSWORD=$admin_password
export OS_AUTH_URL=http://$controller_admin_host:35357/$keystone_api_version
export NOVACLIENT_INSECURE=1
export SAHARACLIENT_INSECURE=1
export NOVA_ENDPOINT_TYPE=internalURL
export OS_ENDPOINT_TYPE=internalURL
export CINDER_ENDPOINT_TYPE=internalURL
export OS_IMAGE_URL=http://$controller_admin_host:9292
export OS_IDENTITY_API_VERSION=$version
export OS_REGION_NAME=$region
export PS1='[\\u@\\h \\W(openstack_$admin_user)]\\$ '
"

  file {"/root/keystonerc_$admin_user":
     ensure  => "present",
     mode => '0600',
     content => $rcadmin_content,
  }

 if $provision_keystone {
   $rcprovision_content = "export OS_USERNAME=$provision_user
export OS_TENANT_NAME=$provision_tenant
export OS_PASSWORD=$provision_password
export OS_AUTH_URL=http://$controller_admin_host:35357/$keystone_api_version
export NOVACLIENT_INSECURE=1
export SAHARACLIENT_INSECURE=1
export NOVA_ENDPOINT_TYPE=internalURL
export OS_ENDPOINT_TYPE=internalURL
export CINDER_ENDPOINT_TYPE=internalURL
export OS_IMAGE_URL=http://$controller_admin_host:9292
export OS_IDENTITY_API_VERSION=$version
export OS_REGION_NAME=$region
export PS1='[\\u@\\h \\W(openstack_$provision_user)]\\$ '
"

  file {"/root/keystonerc_${provision_user}":
     ensure  => "present",
     mode => '0600',
     content => $rcprovision_content,
  } 
 }
}
