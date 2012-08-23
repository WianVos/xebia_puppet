define opendj::person(
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
		"Ldif_${name}_person":
			content => template("opendj/ldif/person.ldif.erb"),
			path	=> "${confdir}/${name}_person.ldif",
			ensure 	=> present	
	}
	
	opendj::ldif{"person_${name}":
		ldifFile => "${confdir}/${name}_person.ldif",
		require => File["Ldif_${name}_person"]
	}
}