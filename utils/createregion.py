#!/usr/bin/python

"""
script to ease creation of new regions
"""

from jinja2 import Environment,FileSystemLoader
import os
import optparse
import sys
import yaml

__author__ = "Karim Boumedhel"
__credits__ = ["Karim Boumedhel"]
__license__ = "GPL"
__version__ = "0.1"
__maintainer__ = "Karim Boumedhel"
__email__ = "karim.boumedhel@gmail.com"
__status__ = "Production"

usage = "script to ease creation of new regions"
version = "0.1"
parser = optparse.OptionParser("Usage: %prog [options]",version=version)
parser.add_option('-d', '--default', dest='default', default=False, action='store_true', help='Accept default options')
(options, args) = parser.parse_args()
default = options.default


THIS_DIR = os.path.dirname(os.path.abspath(__file__))
env = Environment(loader=FileSystemLoader(THIS_DIR),trim_blocks=True)

info = {}

info['region'] = raw_input('Enter value for Region[RegionOne]: ') if not default else 'RegionOne'
region = info['region']
if not os.path.exists(region):
	os.makedirs(region)
else:
	print "Output directory allready there.exiting...."
        sys.exit(1)

#DB
single = raw_input('\nUse Single password ? [true/FALSE]') if not default else 'false'
if single == 'true':
	singlepassword = raw_input('\nEnter value for singlepassword: ')
#passwords 
for password in 'root_db_password', 'cinder_db_password','glance_db_password', 'heat_db_password','sahara_db_password','keystone_db_password','mysql_root_password', 'neutron_db_password','nova_db_password', 'trove_db_password':
	if single == 'true':
 		info[password] = singlepassword		
	else:
		info[password] = os.urandom(16).encode('hex')

info['mysql_host']                     = raw_input('\nEnter value for mysql_host: ')
info['galera_master_name']             = raw_input('\nEnter value for galera_master_name: ')
info['enable_galera']                  = raw_input('\nEnter value for enable_galera[TRUE|false]: ') if not default else 'true'
x                                      =  raw_input('\nEnter values for galera_internal_ips, separated by commas: ')
info['galera_internal_ips']            = yaml.dump(x.split(','),default_flow_style=False).replace('- ', ' - ')[:-1]

#RABBIT
info['amqp_username']                  = raw_input('\nEnter value for amqp_username[rabbit]: ') if not default else 'rabbit'
info['amqp_password']                  = os.urandom(16).encode('hex')
info['amqp_cookie']                    = os.urandom(16).encode('hex')
x                                      = raw_input('\nEnter values for amqp_hosts, separated by commas: ')
info['amqp_hosts']                     = yaml.dump(x.split(','),default_flow_style=False).replace('- ', ' - ')[:-1]

#MONGODB
x                                      = raw_input('\nEnter values for mongodb_servers, separated by commas: ')
info['mongodb_servers']                = yaml.dump(x.split(','),default_flow_style=False).replace('- ', ' - ')[:-1]
info['nongodb_replicaset']             = raw_input('\nEnter value for mongodb_replicaset[replSet]: ') if not default else 'replSet'

#HORIZON
info['verbose']                        = raw_input('\nEnter value for verbose[TRUE/false]: ') if not default else 'true'
info['debug']                          = raw_input('\nEnter value for debug[TRUE/false]: ') if not default else 'true'
info['keystone_api_version']           = raw_input('\nEnter value for keystone_api_version[v2.0]: ') if not default else 'v2.0'
info['horizon_secret_key']             = os.urandom(8).encode('hex')

info['admin_email']                    = raw_input('\nEnter value for admin_email[root@karma.com]: ') if not default else 'root@karma.com'
info['admin_password']                 = os.urandom(16).encode('hex')
info['ceilometer_metering_secret']     = os.urandom(16).encode('hex')
info['ceilometer_user_password']       = os.urandom(16).encode('hex')
info['cinder_backend_nfs']             = raw_input('\nEnter value for cinder_backend_nfs[true|FALSE]: ') if not default else 'false'
if info['cinder_backend_nfs'] == 'true':
	x                              = raw_input('\nEnter values for cinder_nfs_shares, separated by commas: ')
	info['cinder_nfs_shares']      = yaml.dump(x.split(','),default_flow_style=False).replace('- ', ' - ')[:-1]
info['controller_priv_host']           = raw_input('\nEnter value for controller_priv_host: ')
info['controller_admin_host']          = raw_input('\nEnter value for controller_admin_host[CONTROLLER_PRIV_HOST]: ') if not default else info['controller_priv_host']
info['controller_pub_host']            = raw_input('\nEnter value for controller_pub_host[CONTROLLER_PUB_HOST]: ') if not default else info['controller_priv_host']
info['cinder_user_password']           = os.urandom(16).encode('hex')
info['glance_user_password']           = os.urandom(16).encode('hex')
info['heat_user_password']             = os.urandom(16).encode('hex')
info['sahara_user_password']           = os.urandom(16).encode('hex')
info['swift_user_password']            = os.urandom(16).encode('hex')
info['neutron_user_password']          = os.urandom(16).encode('hex')
info['nova_user_password']             = os.urandom(16).encode('hex')
info['keystone_admin_token']           = os.urandom(16).encode('hex')
info['neutron_metadata_proxy_secret']  = os.urandom(16).encode('hex')
info['heat_auth_encrypt_key']          = os.urandom(16).encode('hex')
info['public_url_keystone']            = raw_input('\nEnter value for public_url_keystone[]: ')        if not default else ''
info['public_url_ceilometer']          = raw_input('\nEnter value for public_url_ceilometer[]: ')      if not default else ''
info['public_url_cinder']              = raw_input('\nEnter value for public_url_cinder[]: ')          if not default else ''
info['public_url_glance']              = raw_input('\nEnter value for public_url_glance[]: ')          if not default  else ''
info['public_url_nova']                = raw_input('\nEnter value for public_url_nova[]: ')            if not default else ''
info['public_url_nova_ec2']            = raw_input('\nEnter value for public_url_nova_ec2[]: ')        if not default  else ''
info['public_url_neutron']             = raw_input('\nEnter value for public_url_neutron[]: ')         if not default else ''
info['public_url_swift']               = raw_input('\nEnter value for public_url_swift[]: ')           if not default else ''
info['public_url_heat']                = raw_input('\nEnter value for public_url_heat[]: ')            if not default else ''
info['public_url_heat_cfn']            = raw_input('\nEnter value for public_url_heat_cfn[]: ')        if not default else ''
info['public_url_heat_cloudwatch']     = raw_input('\nEnter value for public_url_heat_cloudwatch[]: ') if not default else ''
info['public_url_sahara']              = raw_input('\nEnter value for public_url_sahara[]: ')          if not default else ''
x                                      = raw_input('\nEnter values for extra_services, separated by commas[ceilometer,swift,sahara]: ') if not default else 'ceilometer,swift,sahara'
info['extra_services']                 = yaml.dump(x.split(','),default_flow_style=False).replace('- ', ' - ')[:-1]
info['provision_glance']               = raw_input('\nEnter value for provision_glance[true/FALSE]: ') if not default else 'false'
if info['provision_glance'] == 'true':
	info['cirros_version']         = raw_input('\nEnter value for cirros_version[0.3.4]: ') if not default else '0.3.4'
info['provision_neutron']              = raw_input('\nEnter value for provision_neutron[true|FALSE]: ') if not default else 'false'
info['provision_glance']               = raw_input('\nEnter value for provision_glance[true|FALSE]: ') if not default else 'false'
if info['provision_neutron'] == 'true':
	info['neutron_public_net']     = raw_input('\nEnter value for neutron_public_net: ')
	info['neutron_public_gateway'] = raw_input('\nEnter value for neutron_public_gateway: ')
	info['neutron_public_start']   = raw_input('\nEnter value for neutron_public_start: ')
	info['neutron_public_end']     = raw_input('\nEnter value for neutron_public_end: ')
info['provision_keystone']             = raw_input('\nEnter value for provision_keystone[true|FALSE]: ') if not default else 'false'
info['glance_nfs_url']                 = raw_input('\nEnter value for glance_nfs_url: ')
info['ovs_tunnel_iface']               = raw_input('\nEnter value for ovs_tunnel_iface: ')
info['enable_agent']                   = raw_input('\nEnter value for enable_agent[TRUE/false]: ') if not default else 'true'
info['vncproxy_host']                  = raw_input('\nEnter value for vncproxy_host[CONTROLLER_PRIV_HOST|false]: ') if not default else info['controller_priv_host']

#SWIFT
info['swift_ringserver_ip']            = raw_input('\nEnter value for swift_ringserver_ip: ') if not default else info['controller_priv_host']
x                                      = raw_input('\nEnter value for swift_storage_ips separated by commas: ')
info['swift_storage_ips']              = yaml.dump(x.split(','),default_flow_style=False).replace('- ', ' - ')[:-1]
info['swift_storage_device']           = raw_input('\nEnter value for swift_storage_devices[vdb1]: ') if not default else 'vdb1'
info['swift_shared_secret']            = os.urandom(8).encode('hex')
info['swift_local_interface']          = raw_input('\nEnter value for swift_local_interface[eth0]: ') if not default else 'eth0'
info['swift_storage_fstype']           = raw_input('\nEnter value for swift_storage_fstype[xfs]: ') if not default else 'xfs'

#PACEMAKER
x                                      = raw_input('\nEnter value for cluster_members separated by commas: ')
info['cluster_members']                = yaml.dump(x.split(','),default_flow_style=False).replace('- ', ' - ')[:-1]
info['cluster_vip']                    = raw_input('\nEnter value for cluster_vip: ')
info['cluster_vipmask']                = raw_input('\nEnter value for cluster_vipmask[24]: ') if not default else '24'
info['stonith']                        = raw_input('\nEnter value for stonith[true|FALSE]: ') if not default else 'false'
if info['stonith'] != 'false':
	info['stonith_type']                   = raw_input('\nEnter value for stonith_type[rhevm|xxx]: ')
	if info['stonith_type'] == 'rhevm':
		info['rhevm_login']            = raw_input('\nEnter value for rhevm_login[admin@internal]: ') if not default else 'admin@internal'
		info['rhevm_passwd']           = raw_input('\nEnter value for rhevm_passwd: ')
		info['rhevm_ipaddr']           = raw_input('\nEnter value for rhevm_ipaddr: ')

#NETWORK
info['agent_type']                     = raw_input('\nEnter value for agent_type[OVS|nuage|opendaylight]: ') if not default else 'ovs'
info['enable_tunneling']               = raw_input('\nEnter value for enable_tunneling[TRUE|false]: ') if not default else 'true'

#COMPUTE
info['private_network']                = raw_input('\nEnter value for private_network: ')
info['private_iface']                  = raw_input('\nEnter value for private_iface: ')
info['tenant_network_type']            = raw_input('\nEnter value for tenant_network_type[vxlan|gre|vlan]: ') if not default else 'vxlan'

#HAPROXY
info['haproxy_vip']                    = raw_input('\nEnter value for haproxy_vip: ')
x                                      = raw_input('\nEnter value for haproxy_servers separated by commas: ')
info['haproxy_servers']                = yaml.dump(x.split(','),default_flow_style=False).replace('- ', ' - ')[:-1]
info['haproxy_ips']                    = info['haproxy_servers']

db                                     = env.get_template('db.yaml').render(info)
rabbitmq                               = env.get_template('rabbitmq.yaml').render(info)
mongodb                                = env.get_template('mongodb.yaml').render(info)
api                                    = env.get_template('api.yaml').render(info)
network                                = env.get_template('network.yaml').render(info)
compute                                = env.get_template('compute.yaml').render(info)
haproxy                                = env.get_template('haproxy.yaml').render(info)
horizon                                = env.get_template('horizon.yaml').render(info)
swift                                  = env.get_template('swift.yaml').render(info)
pacemaker                              = env.get_template('pacemaker.yaml').render(info)
hacontroller                           = env.get_template('hacontroller.yaml').render(info)

with open("%s/db.yaml" % region, 'w') as f:
    f.write(db)
with open("%s/rabbitmq.yaml" % region, 'w') as f:
    f.write(rabbitmq)
with open("%s/mongodb.yaml" % region, 'w') as f:
    f.write(mongodb)
with open("%s/api.yaml" % region, 'w') as f:
    f.write(api)
with open("%s/swift.yaml" % region, 'w') as f:
    f.write(swift)
with open("%s/horizon.yaml" % region, 'w') as f:
    f.write(horizon)
with open("%s/pacemaker.yaml" % region, 'w') as f:
    f.write(pacemaker)
with open("%s/network.yaml" % region, 'w') as f:
    f.write(network)
with open("%s/compute.yaml" % region, 'w') as f:
    f.write(compute)
with open("%s/haproxy.yaml" % region, 'w') as f:
    f.write(haproxy)
with open("%s/hacontroller.yaml" % region, 'w') as f:
    f.write(hacontroller)
