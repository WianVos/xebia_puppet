define opendj::ou(
	$ensure = "present",
	$confdir = "${opendj::confdir}",
	$domainName = "none",
	$parent_ou = "none",
	$ou		= "${name}",
	$parent
){
	#setting the dn
	case $domainName {
		"none": { $dn = "ou=${ou},dc=${opendj::universe},${opendj::basednsuffix}"
		}
		default: {$dn = "ou=${ou},${domainName}"}
	}
	
	case $domainName {
		
	}
	
	case $ensure {
		"absent": { $changeType="delete"}
		default : { $changeType="add"   }
	}
	
	file{
		"Ldif_${name}_ou":
			content => template("opendj/ldif/ou.ldif.erb"),
			path	=> "${confdir}/${name}_ou.ldif",
			ensure 	=> present	
	}
	
	opendj::ldif{"ou_${name}":
		ldifFile => "${confdir}/${name}_ou.ldif",
		require => File["Ldif_${name}_ou"]
	}
}