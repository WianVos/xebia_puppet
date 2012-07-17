class splunk::params{
	
	
	$infra_dir				= "/etc/xebia_puppet"
	$marker_dir 			= "${infra_dir}/marker"
	$script_dir 			= "${infra_dir}/script"
	$config_dir 			= "${infra_dir}/config"
	$tmpdir						= 	"/var/tmp/splunk"
	$basedir					=	'/opt'
	$homedir					=	"${basedir}/splunk"
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
	$install_owner				=	'splunk'
	$install_group				=	'splunk'
	$packages					=	['unzip']
	
	# splunk specific settings
	$puppetfiles_tarfile				= "splunk-4.3-115073-Linux-x86_64.tgz"
	$puppetfiles_source			= "puppet:///modules/splunk/install_tar/${puppetfiles_tarfile}"
	$default_passwd				= admin
	$admin_passwd				= test # override in hiera ... duh
	$admin_user					= admin # should change
	
}
