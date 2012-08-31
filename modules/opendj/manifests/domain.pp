define opendj::domain(
	$ensure = "present",
	$confdir = "${opendj::confdir}",
	$dn = "none", 	
	$dc = "${name}"		
){
	
	case $dn {
		"none": {$dc = "dc=${dc},dc=${opendj::universe},dc=${opendj::basednsuffix}"}
		default: {$dn = "dc=${dc},${dn}"}
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