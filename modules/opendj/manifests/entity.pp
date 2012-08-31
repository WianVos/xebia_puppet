define opendj::entity(
	$ensure = "present",
	$confdir = "${opendj::confdir}",
	$dn	
	
){
	# set ensure
	case $ensure {
		"absent": { $changeType="delete"}
		default : { $changeType="add"   }
	}
	# get the first part of the name (being the dn) 
	$firstPart = inline_template("<%= dn.split(\",\").first %>")
	$ident 		= inline_template("<%= firstPart.split(\"=\").first %>")
	$entity_name = inline_template("<%= firstPart.split(\"=\").second %>")		
	
	
	case $ident {
		"ou" : { $template = "ou.ldif.erb"
				 $ou = "$firstPart"
				 
		}
		"dc" : { $template = "domain.ldif.erb"
				 $dc = "$firstPart"
		}
	}	
	
	
	
	
	
	
	
	file{
		"Ldif_${entity_name}_${ident}":
			content => template("opendj/ldif/${template}"),
			path	=> "${confdir}/${entity_name}_${ident}.ldif",
			ensure 	=> present	
	}
	
	opendj::ldif{"${ident}_${entity_name}":
		ldifFile => "${confdir}/${entity_name}_${ident}.ldif",
		require => File["Ldif_${entity_name}_${ident}"]
	}
}