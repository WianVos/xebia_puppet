class postgresql::params{
	
	
	$infra_dir				= "/etc/xebia_puppet"
	$marker_dir 			= "${infra_dir}/marker"
	$script_dir 			= "${infra_dir}/script"
	$config_dir 			= "${infra_dir}/config"
	$tmpdir						= 	'/var/tmp/postgresql'
	$basedir					=	'/opt'
	$homedir					=	"${basedir}/postgresql"
	$datadir					=	'/data/'
	$absent 					=	false
	$ensure						= 	false
	$disabled 					= 	false
	$ensure						= 	'running'
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
	$packages					=	''
	
	# postgresql specific settings
	$version					= "9.1.2"
	
}