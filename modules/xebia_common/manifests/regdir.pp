class xebia_common::regdir(
	$absent 	= 	false,
	$baseregdir	=	"/etc/xebia_puppet",
	$script_dir	=	"",
	$config_dir	=	"",
	$marker_dir	=	""
){
	
	$scriptDir	=	$script_dir ?{
		''			=>	"${baseregdir}/script",
		default 	=>	$script_dir
	}
	$configDir	=	$config_dir ?{
		''			=>	"${baseregdir}/config",
		default 	=>	$config_dir
	}
	$markerDir	=	$marker_dir ?{
		''			=>	"${baseregdir}/marker",
		default 	=>	$marker_dir
	}
	
	$factDir	=	"/etc/puppetlabs/facter/facts.d"
	
	$manage_directory = $absent ? {
		true 	=> "absent",
		default => "directory"
	}


	File { owner => root, group => root, mode => "744", ensure => "${manage_directory}" }
	
	if !defined(File["${baseregdir}"]) {
		
		file {"${baseregdir}":}
		
		file {["${scriptDir}","${configDir}","${markerDir}","${factDir}"]:
			require		=>	File["${baseregdir}"]
		}
	
	}

}



