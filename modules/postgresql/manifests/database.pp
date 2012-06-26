define postgresql::database (
	$owner,
	$install_owner = params_lookup('install_owner'),
	$ensure	= params_lookup('ensure')
	) 
	{
	
	$dbexists = "psql -ltA | grep '^${name}|'"
	
	if ! defined(Postgresql::User["${owner}"]) {
		postgresql::user {
		"${owner}":
			ensure => $ensure,
		
		}
	}
	if $ensure == 'present' {
		exec {
			"createdb $name" :
				command => "createdb -O ${owner} ${name}",
				user => "${install_owner}",
				unless => $dbexists,
				require => Postgresql::User[$owner],
		}
	}
	elsif $ensure == 'absent' {
		exec {
			"dropdb $name" :
				command => "dropdb ${name}",
				user => "${install_owner}",
				onlyif => $dbexists, 
				before => Postgresql::User[$owner],
		}
	}
}



