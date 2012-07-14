class jetty::params{
	
	$infra_dir				= "/etc/xebia_puppet"
	$marker_dir 			= "${infra_dir}/marker"
	$script_dir 			= "${infra_dir}/script"
	$config_dir 			= "${infra_dir}/config"
	$source_dir				= "/opt/jetty_source"
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
	$install_source_url		= "http://ftp.osuosl.org/pub/eclipse/jetty/${version}/dist/jetty-distribution-${version}.tar.gz"
	$export_facts			= false
	$export_config			= false
	$import_facts			= true
	$import_config			= true
	$universe				= "general"
	$customer				= "default"
	$application			= "default_app"
	$stage					= "test"
	$instances 				= { 'test1' => {port => 8080 ,basedir => "${basedir}",application => "test", customer => "xebia_puppet", stage => "test"},
								'test2' => {port => 8090 ,basedir => "${basedir}",application => "test", customer => "xebia_puppet", stage => "test"},
								'test3' => {port => 8100 ,basedir => "${basedir}",application => "test", customer => "xebia_puppet", stage => "test"}}
	
}
