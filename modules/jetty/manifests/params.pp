class jetty::params{
	
	$marker_dir 			= "/etc/xebia_puppet/marker"
	$script_dir 			= "/etc/xebia_puppet/scripts"
	$config_dir 			= "/etc/xebia_puppet/config"
	$packages 				= ['openjdk-6-jdk']
	$version 				= '8.1.4.v20120524'
	$basedir 				= "/opt/jetty_base"
	$absent 				= false
	$disabled 				= false
	$ensure					= true
	$install				= source
	$install_filesource		= undef
	$install_owner			= "jetty"
	$install_group			= "jetty"
	$install_source_url		= "http://download.eclipse.org/jetty/${version}/dist/jetty-distribution-${version}.tar.gz"
	$export_facts			= false
	$export_config			= false
	$import_facts			= true
	$import_config			= true
	$xebia_universe			= "general"
	$customer				= "default"
	$application			= "default_app"
		
	
}
