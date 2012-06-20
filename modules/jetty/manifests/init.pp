#
#
class jetty(
	$packages 				= params_lookup('packages'), 
	$version 				= params_lookup('version'),
	$basedir 				= params_lookup('basedir'),
	$homedir 				= params_lookup('homedir'),
	$tmpdir					= params_lookup('tmpdir'),
	$source_dir				= params_lookup('source_dir'),
	$infra_dir				= params_lookup('infra_dir'),
	$config_dir				= params_lookup('config_dir'),
	$script_dir				= params_lookup('script_dir'),
	$marker_dir				= params_lookup('marker_dir'),
	$absent 				= params_lookup('absent'),
	$disabled 				= params_lookup('disabled'),
	$ensure					= params_lookup('ensure'),
	$install				= params_lookup('install'),
	$install_filesource		= params_lookup('install_filesource'),
	$install_owner			= params_lookup('install_owner'),
	$install_group			= params_lookup('install_group'),
	$install_source_url		= params_lookup('install_source_url'),
	$export_facts			= params_lookup('export_facts'),
	$export_config			= params_lookup('export_configs'),
	$import_facts			= params_lookup('import_facts'),
	$import_config			= params_lookup('import_config'),
	$universe				= params_lookup('universe', global),
	$customer				= params_lookup('customer', global),
	$application			= params_lookup('application', global),
	$instances				= params_lookup('instances')
		
) inherits jetty::params{
	
	#set various manage parameters in accordance to the $absent directive
	$manage_package = $absent ? {
		true 	=> "absent",
		false 	=> "installed",
		default => "installed"
	}
	
	$manage_directory = $absent ? {
		true 	=> "absent",
		default => "directory",
	}
	
	$manage_link = $absent ? {
		true 	=> "absent",
		default => "link",
	}
	
	$manage_files = $absent ? {
		true 	=> "absent",
		false 	=> "present",
		default => "present"
	}
	
	$manage_user = $absent ? {
		true 	=> "absent",
		false 	=> "present",
		default => "present"
	}
	

	$ensure_service = $ensure ? {
		true	=> "running",
		false 	=> "stoppped",
		default	=> "running"
	}
	
	#install packages as needed by jetty	
	package{ $packages:
		ensure => $manage_package,
		before => File["$basedir"]
	}
	
	#create the needed users
	group {
		"$install_group":
			ensure => $manage_user,
	}
	
	user {
		"$install_owner":
			ensure 		=> $manage_user,
			gid 		=> "${install_group}",
			managehome 	=> false,
			home 		=> "${homedir}",
			system 		=> true,
			
	}
	
	#basedir
	file {"${basedir}":
		ensure 	=> "${manage_directory}",
		owner 	=> "root",
		group	=> "root",
		mode	=> "2775",
	}
	
	file {"${source_dir}":
		ensure 	=> "${manage_directory}",
		owner	=> root,
		group	=> root,
		mode	=> "2770"
	}
	
	

	#setup infra 
	file {["${infra_dir}","${marker_dir}","${script_dir}","${config_dir}"]:
		ensure 	=> "${manage_directory}",
		owner  	=> root,
		group	=> root,
		mode	=> 770,
	}
	 
	
	
	if $import_facts {
		
		#import the 
		Xebia_common::Features::Export_facts <<| tag == "${universe}-deployit-service" |>>
	}
	
	if $import_config {
		
		#import the 
		Xebia_common::Features::Export_facts <<| tag == "${universe}-deployit-service-config" |>>
	}
	
	
	
#populate the basedir with the appropriate source
	xebia_common::source {
	"${name}_unpack_jetty-${version}" :
		source_url => "${install_source_url}",
		target => "${source_dir}",
		regdir => "${marker_dir}",
		type => "targz",
		timeout => "2400",
		owner => "${install_owner}",
		group => "${install_group}",
		require => File["${infra_dir}","${marker_dir}","${script_dir}","${config_dir}","${source_dir}"]
	}
     
    file {
    	"jetty-source-${version}" :
    		path => "${source_dir}/jetty-distribution-${version}",
    		ensure => "${manage_directory}",
    		mode => "750",
    		require => Xebia_common::Source["${name}_unpack_jetty-${version}"],
    		owner => "${install_owner}",
    		group => "${install_group}"
    }
    
	create_resources(jetty::instance, $instances )
  	#deployit_cli::types::jetty_ssh{"jetty instance":
	#			environments => "general",
	#			require => Service["jetty"]
	#}
  	
}
