class deployit::params{
	
	
	
	$packages 					= 	['openjdk-6-jdk', 'unzip']
	$version 					= 	'3.7.0'
	$basedir 					= 	'/opt/deployit_base'
	$homedir 					= 	'/opt/deployit'
	$tmpdir						= 	'/var/tmp/deployit'
	$absent 					=	false
	$disabled 					= 	false
	$ensure						= 	'running'
	$install					= 	'files'
	$install_filesource			= 	'puppet:///modules/deployit'
	$install_owner				= 	'deployit'
	$install_group				= 	'deployit'
	$admin_password				= 	'admin'
	$jcr_repository_path		= 	'repository'
	$threads_min				= 	'4'
	$threads_max				= 	'32'
	$ssl						= 	false
	$http_bind_address			= 	'0.0.0.0'
	$http_context_root			= 	'/'
	$http_port					=   '4516'
	$importable_packages_path	= 	"importablePackages"
	$universe					= 	'general'
	$plugin_install				= 	true
	$export_facts				= 	true
	$export_config				= 	true
	$confdir					= 	'/etc/xebia_puppet/config'
	$scriptdir					= 	'/etc/xebia_puppet/scriptsdir'
	$markerdir					= 	'/etc/xebia_puppet/marker'
	$import_facts				= 	false
	$import_config				= 	false
			
}
