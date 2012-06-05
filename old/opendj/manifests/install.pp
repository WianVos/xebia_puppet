class opendj::install(
	$basedn="dc=example,dc=com",
	$ldapport="389",
	$adminport="4444",
	$rootuser="Directory Manager",
	$rootpassword="xita01"
){

	include opendj::params
	
	exec {"opendj install":
		command => "${opendj::params::installpath}/OpenDJ-2.4.4/setup --cli --baseDN ${basedn} --ldapPort ${ldapport} --adminConnectorPort ${adminport} --rootUserDN cn=\'${rootuser}\' --rootUserPassword ${rootpassword} --no-prompt --noPropertiesFile && touch ${opendj::params::installpath}/OpenDJ-2.4.4/puppetinstalledopendj.txt ",
		creates => "${opendj::params::installpath}/OpenDJ-2.4.4/puppetinstalledopendj.txt",
		}

}
