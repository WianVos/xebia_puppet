class git::params{
	
	
	$version 					= 	'3.7.3'
	$basedir 					= 	'/opt/git_base'
	$homedir 					= 	'/opt/git'
	$install_package			=	'git'
	$install_filesource			= 	'puppet:///modules/git'
	$install_owner				= 	'git'
	$install_group				= 	'git'
	$plugin_install				= 	true
	$key_install				= 	true

	#universe settings
	$universe					= 	'general'

	#module management settings
	$packages 					= 	['openjdk-6-jdk', 'unzip']
	$tmpdir						= 	'/var/tmp/git'
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