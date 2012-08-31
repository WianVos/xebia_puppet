define opendj::ou(
	$ensure = "present",
	$confdir = "${opendj::confdir}",
	$dn = "none",
	$ou		= "${name},"
){
	#setting the dn
	case $dn {
		"none": {$dn = "ou=${ou},dc=${opendj::universe},dc=${opendj::basednsuffix}"}
		default: {$dn = "ou=${ou},${dn}"}
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