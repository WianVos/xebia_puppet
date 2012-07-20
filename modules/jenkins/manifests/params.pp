class jenkins::params{
	
	
	$version 					= 	'3.7.3'
	$basedir 					= 	'/opt/jenkins_base'
	$homedir 					= 	'/opt/jenkins'
	$install_filesource			= 	'puppet:///modules/jenkins'
	$install_package			=	"jenkins"
	$install_owner				= 	'jenkins'
	$install_group				= 	'jenkins'
	$plugin_install				= 	true
	$key_install				= 	true

	#universe settings
	$universe					= 	'general'

	#module management settings
	$packages 					= 	['openjdk-6-jdk', 'unzip']
	$tmpdir						= 	'/var/tmp/jenkins'
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