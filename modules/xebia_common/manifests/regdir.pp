class xebia_common::regdir(
	$absent 	= 	false,
	$basedir 	= 	"/etc",
	$baseregdir	=	"xebia_puppet"
){
	
	$scriptdir	=	"${basedir}/${baseregdir}/bin"
	$configdir	=	"${basedir}/${baseregdir}/etc"
	$markerdir	=	"${basedir}/${baseregdir}/marker"
	$factdir	=	"/etc/facts.d"
	
	$manage_directory = $absent ? {
		true 	=> "absent",
		default => "directory"
	}


	File { owner => root, group => root, mode => "744", ensure => "${manage_directory}" }
	
	if !defined(File["${basedir}/${baseregdir}"]) {
		
		file {"${basedir}/${baseregdir}":}
		
		file {["${scriptdir}","${configdir}","${markerdir}","${factdir}"]:
			require		=>	File["${$basedir}/${baseregdir}"]
		}
	
	}

}



