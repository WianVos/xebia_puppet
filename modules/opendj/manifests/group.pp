define opendj::group(
	$ensure = "present",
	$confdir = "${opendj::confdir}",
	$cn		= "${name}",
	$dn, 	
	$ou
	
){
	case $ensure {
		"absent": { $changeType="delete"}
		default : { $changeType="add"   }
	}
	
	file{
		"Ldif_${name}_group":
			content => template("opendj/ldif/group.ldif.erb"),
			path	=> "${confdir}/${name}_group.ldif",
			ensure 	=> present	
	}
	
	opendj::ldif{"group_${name}":
		ldifFile => "${confdir}/${name}_group.ldif"
	}
}