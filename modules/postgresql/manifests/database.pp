define postgresql::database (
	$owner,
	$install_owner = params_lookup('install_owner'),
	$ensure	= present,
	$homedir = params_lookup('homedir')
	
	) 
	{
	
	$dbexists = "${homedir}/bin/psql -ltA | grep '^${name}|'"
	
	if ! defined(Postgresql::User["${owner}"]) {
		postgresql::user {
		"${owner}":
			ensure => $ensure,
		
		}
	}
	if $ensure == 'present' {
		exec {
			"createdb $name" :
				command => "${homedir}/bin/createdb -O ${owner} ${name}",
				user => "${install_owner}",
				unless => $dbexists,
				require => Postgresql::User[$owner],
		}
	}
	elsif $ensure == 'absent' {
		exec {
			"dropdb $name" :
				command => "${homedir}/bin/dropdb ${name}",
				user => "${install_owner}",
				onlyif => $dbexists, 
				before => Postgresql::User[$owner],
		}
	}
}



