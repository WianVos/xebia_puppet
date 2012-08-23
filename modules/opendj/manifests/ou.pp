define opendj::ou(
	$ensure = "present",
	$confdir = "${opendj::confdir}",
	$dn, 	
	$ou		= "${name}"
){
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