define opendj::ldif (
	$ldifFile,
	$rootuser = "${opendj::rootuser}",
	$rootpassword = "${opendj::rootpassword}",
	$ldapport = "${opendj::ldapport}",
	$hostname = "localhost",
	$markerdir = "${opendj::markerdir}") {
	
	exec {
		"${name}_ldiff" :
			#require => [Package["ldap-utils"], Service["opendj"]],
			command =>
			"/usr/bin/ldapmodify -h 'localhost' -p ${ldapport} -D \"${rootuser}\" -w ${rootpassword} -f ${ldifFile} && touch ${markerdir}/${name}_ldif ",
			creates => "${markerdir}/${name}_ldif",
			logoutput => true,
			returns => [0, 68, 32],
			#onlyif => ["/usr/bin/test -f ${markerdir}", "/usr/bin/test -f ${ldifFile}"]
	}
}