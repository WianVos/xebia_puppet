production_mode_enabled=True
overwrite_domain=True

# installation locations
middleware_home='/opt/weblogic/Middleware'
java_home='/opt/weblogic/Middleware/jdk160_21'


# Templates to load in the domain
baseTemplate=middleware_home + '/wlserver_10.3/common/templates/domains/wls.jar'
extensionTemplates=[]

domain_dir_default='/data/user_projects/domains/<domain_name>'
app_dir_default='/data/user_projects/applications/<domain_name>'

#domain_default={'AdministrationPortEnabled': True}
domain_default={}
domain_logging_default={'FileName':'/data/logs/<domain_name>/<domain_name>.log',
                'RotationType': 'none',
                'RotateLogOnStartup': False}

cluster_template={'Name':'<domain_name>-Cluster',
                  'ClusterBroadcastChannel': 'ClusterBroadcast',
                  'WeblogicPluginEnabled': True}

machines_default=['admin_server_machine']
machine_template={'Name':'<domain_name>-MS<number>',
                  'ListenPort':5552}
                 
admin_server_machine_default={'Name':'<domain_name>-Admin',
                      'ListenPort':5552}
admin_server_default={'IgnoreSessionsDuringShutdown': True,
                      'Machine':'<domain_name>-Admin',
                      'TunnelingEnabled': True,
                      'UploadDirectoryName':'/data/deploy'}
admin_server_logging_default={'FileName':'/data/logs/<domain_name>/AdminServer.log',
                      'RedirectStderrToServerLogEnabled': True,
                      'RedirectStdoutToServerLogEnabled': True,
                      'DomainLogBroadcastSeverity': 'Warning',
                      'LogFileSeverity': 'Warning',
                      'LoggerSeverity': 'Warning',
                      'MemoryBufferSeverity': 'Warning',
                      'RotationType': 'none',
                      'RotateLogOnStartup': False,
                      'StdoutSeverity': 'Warning'}
admin_server_webserver_default={'WebServerLog':{'FileName':'/data/logs/<domain_name>/' + 'AdminServer.access', 'RotationType': 'none', 'RotateLogOnStartup': False}}


managed_server_template={'Name':'<domain_name>-MS<number>',
                         'IgnoreSessionsDuringShutdown': False,
                         'Machine':'<domain_name>-MS<number>',
                         'TunnelingEnabled': True,
                         'WeblogicPluginEnabled': True}
managed_server_logging_template={'FileName':'/data/logs/<domain_name>/<domain_name>-MS<number>.log',
                    'RedirectStderrToServerLogEnabled': True,
                    'RedirectStdoutToServerLogEnabled': True,
                    'DomainLogBroadcastSeverity': 'Warning',
                    'LogFileSeverity': 'Warning',
                    'LoggerSeverity': 'Warning',
                    'MemoryBufferSeverity': 'Warning',
                    'RotationType': 'none',
                    'RotateLogOnStartup': False,
                    'StdoutSeverity': 'Warning'}
managed_server_serverstart_template={'Arguments': '-Xms1024m -Xmx1024m -XX:MaxPermSize=128m  -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=<listen_port+1> -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dweblogic.Stdout=/data/logs/<domain_name>/<domain_name>-MS<number>.stdout -Dweblogic.Stderr=/data/logs/<domain_name>/<domain_name>-MS<number>.stderr'}
managed_server_webserver_template={'WebServerLog':{'FileName':'/data/logs/<domain_name>/<domain_name>-MS<number>.access', 'RotationType': 'none', 'RotateLogOnStartup': False, 'LogFileFormat': 'extended', 'ELFFields':'date time cs-method cs-uri sc-status time-taken x-UserAgent x-XForwardedFor'}}
managed_server_network_access_points_template=['<managed_server>_cluster_broadcast_channel']
managed_server_cluster_broadcast_channel_template={
                   'Name': 'ClusterBroadcast',
                   'HttpEnabledForThisProtocol': False,
                   'OutboundEnabled': True,
                   'Protocol': 'cluster-broadcast'}

virtual_hosts_default=[]
virtual_host_template={'Target':'<domain_name>-Cluster'}
virtual_host_logging_template={'FileName':'/data/logs/<domain_name>/virtual_hosts/<instance_name>.access', 'RotationType': 'none', 'RotateLogOnStartup': False, 'LogFileFormat': 'extended', 'ELFFields':'date time cs-method cs-uri sc-status time-taken x-UserAgent x-XForwardedFor'}

# Rename existing (template) servers
# rename_servers={'old_server_name':wl_server1['Name']}
rename_servers={}

jdbcresources=[]

users_default=['monitor']
monitor={'Name':'monitor',
    'UserPassword':'m0nit0r1',
    'GroupMemberOf': 'Monitors,Operators'}
