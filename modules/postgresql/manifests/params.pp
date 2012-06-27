class postgresql::params{
	
	
	$infra_dir				= "/etc/xebia_puppet"
	$marker_dir 			= "${infra_dir}/marker"
	$script_dir 			= "${infra_dir}/script"
	$config_dir 			= "${infra_dir}/config"
	$tmpdir						= 	"/var/tmp/postgresql"
	$basedir					=	'/opt'
	$homedir					=	"${basedir}/postgresql"
	$datadir					=	'/data/'
	$absent 					=	false
	$ensure						= 	false
	$disabled 					= 	false
	$import_facts				= 	true
	$import_config				= 	true
	$export_facts				= 	true
	$export_config				= 	true
	$universe					=   'default'
	$customer					=	'default'
	$application				=	'default'
	$install					=	'puppetfiles'
	$install_owner				=	'postgresql'
	$install_group				=	'postgresql'
	$packages					=	['unzip']
	
	# postgresql specific settings
	$version					= "9.1.4"
	$puppetfiles_tarfile				= "postgresql-${version}-lucid.tar.gz"
	$puppetfiles_source			= "puppet:///modules/postgresql/install_tar/${puppetfiles_tarfile}"
	$server_type				= "standalone"
	$port						= "5432"
	$listen_addresses			= "'0.0.0.0'"
	$max_connections			= "100"
	$shared_buffers				= "24MB"
	
	$postgresConfBaseOptions	= { port => "${port}",
									listen_addresses => "${listen_addresses}",
									max_connections	=> "${max_connections}",
									shared_buffers => "${shared_buffers}"
								}
									
									
	$postgresLoggingOptions		= {	logging_collector => "on",
									log_filename => "'%A.log'",
									log_line_prefix => "'%p %t '",
									log_truncate_on_rotation => "on",
									log_statement => "'all'"}								
	
	#clustering settings
	$pg_pool					= true								
	$streaming_replication		= "slave"	
	$sr_role					= "master"
	$sr_user					= "sruser"
	$sr_user_password			= "replication"
	$streamingReplicationMaster	= { hot_standby => "on",
									wal_level   => "hot_standby",
									max_wal_senders => "1"}	
	$srSlaveOptions 			= {"primary_conninfo" => "\'host=${::fqdn} port=${port} user=${sr_user}\'", 
								   "standby_mode" => "on"}
	$streamingReplicationSlave	= { hot_standby => "on",
									}	
									
	
	
}
