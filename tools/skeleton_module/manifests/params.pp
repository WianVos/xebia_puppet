class skeleton::params{
	
	$version 					= 	'3.7.3'
	$basedir 					= 	'/opt/skeleton_base'
	$homedir 					= 	'/opt/skeleton'
	$install_filesource			= 	'puppet:///modules/skeleton'
	$install_owner				= 	'skeleton'
	$install_group				= 	'skeleton'
	$plugin_install				= 	true
	$key_install				= 	true

	#universe settings
	$universe					= 	'general'

	#module management settings
	$packages 					= 	['openjdk-6-jdk', 'unzip']
	$tmpdir						= 	'/var/tmp/skeleton'
	$absent 					=	false
	$disabled 					= 	false
	$ensure						= 	'running'
	$import_facts				= 	true
	$import_config				= 	true
	$baseconfdir				=	'/etc/xebia_puppet'
	$confdir					= 	'/etc/xebia_puppet/config'
	$scriptdir					= 	'/etc/xebia_puppet/script'
	$markerdir					= 	'/etc/xebia_puppet/marker'
	$export_facts				= 	true
	$export_config				= 	true
	$install					= 	'files'
	
			
}
