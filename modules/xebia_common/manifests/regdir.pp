class xebia_common::regdir(
	$absent 	= 	false,
	$basedir 	= 	"/etc",
	$baseregdir	=	"xebia_puppet"
){
	
	$scriptdir	=	"${basedir}/${baseregdir}/bin"
	$configdir	=	"${basedir}/${baseregdir}/etc"
	$markerdir	=	"${basedir}/${baseregdir}/marker"
	
	$manage_directory = $absent ? {
		true 	=> "absent",
		default => "directory"
	}


	File { owner => root, group => root, mode => "744", ensure => "${manage_directory}" }
	
	if !defined(File["${basedir}/${baseregdir}"]) {
		
		file {"${basedir}/${baseregdir}":}
		
		file {["${scriptdir}","${configdir}","${markerdir}"]:
			require		=>	File["${$basedir}/${baseregdir}"]
		}
	
	}

}



