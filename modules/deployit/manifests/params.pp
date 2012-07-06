class deployit::params{
	
	$version 					= 	'3.7.3'
	$basedir 					= 	'/opt/deployit_base'
	$homedir 					= 	'/opt/deployit'
	$install_filesource			= 	'puppet:///modules/deployit'
	$install_owner				= 	'deployit'
	$install_group				= 	'deployit'
	$plugin_install				= 	true
	$key_install				= 	true

	#deployit config settings
	$admin_password				= 	'admin'
	$jcr_repository_path		= 	'repository'
	$threads_min				= 	'4'
	$threads_max				= 	'32'
	$ssl						= 	false
	$http_bind_address			= 	'0.0.0.0'
	$http_context_root			= 	'/'
	$http_port					=   '4516'
	$importable_packages_path	= 	"importablePackages"

	#universe settings
	$universe					= 	'general'

	#module management settings
	$packages 					= 	['openjdk-6-jdk', 'unzip']
	$tmpdir						= 	'/var/tmp/deployit'
	$absent 					=	false
	$disabled 					= 	false
	$ensure						= 	'running'
	$import_facts				= 	true
	$import_config				= 	true
	$confdir					= 	'/etc/xebia_puppet/config'
	$scriptdir					= 	'/etc/xebia_puppet/script'
	$markerdir					= 	'/etc/xebia_puppet/marker'
	$export_facts				= 	true
	$export_config				= 	true
	$install					= 	'files'
	$cli_conf_options 				= 	{ 	"deployit_hostname"    => "${::fqdn}",
                                                		"deployit_ipaddress"   => "${::ipaddress}",
                                                		"deployit_user"        => "admin",
                                                		"deployit_password"    => "${admin_password}",
                                                		"deployit_port"        => "${http_port}" 
							}
	
			
}
