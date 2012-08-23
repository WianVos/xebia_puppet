define opendj::features::domain(
	$dn,
	$dc = "$name"
){
	file{"domain $dc-$dn":
		content => "dn"
	}
}