define opendj::ldif(
	$ensure 	= "present",
	$ldiffFile,
	$rootuser		= "${opendj::rootuser}",
	$rootpassword	= "${opendj::rootpassword}",
	$ldapport		= "${opendj::ldapport}",
	$hostname		= "localhost",
	$markerdir		= "${opendj::markerdir}"	
){
	exec{ "${name}_ldiff":
		require => [Package["ldap-utils"],Service["opendj"]],
		command => "/usr/bin/ldapmodify -h 'localhost' -p ${ldapport} -D \"${rootuser}\" -w ${rootpassword} -f ${ldiffFile} && touch ${markerdir}/${name}_ldiff ",
		creates => "${markerdir}/${name}_ldiff",
		logoutput 	=> true,
	}
	
}