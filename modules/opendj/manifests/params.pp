class opendj::params{
	
	
	$version 					= 	'2.4.4'
	$homedir 					= 	'/opt/OpenDJ-${version}'
	$install_owner				= 	'opendj'
	$install_group				= 	'opendj'
	
	$install_file				= 	"OpenDJ-${version}.zip"
	$install_filesource			= 	'puppet:///modules/opendj/${install_file}'
	$install_source_url			=   "http://download.forgerock.org/downloads/opendj/${version}/${install_file}"
	


	#universe settings
	$universe					= 	'general'

	#module management settings
	$packages 					= 	['openjdk-6-jdk', 'unzip']
	$tmpdir						= 	'/var/tmp/opendj'
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
	$install					= 	'source'
	
	# opendj settings
	$ldapport					=	'389'
	$mgtport					=	'4444'
	$basedn						=	"dc=${universe},dc=com"
	$rootuser					=	"Directory Manager"
	$rootpassword				=	"xebiapuppet01"
	
											  
	

}