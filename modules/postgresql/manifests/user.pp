define postgresql::user(
	$install_owner = params_lookup('install_owner'),
	$ensure	= params_lookup('ensure'),
	$homedir = params_lookup('homedir'),
	$database = "template1",
	$password = "changeme"
){
	$userexists = "${homedir}/bin/psql ${database} --tuples-only -c 'SELECT rolname FROM pg_catalog.pg_roles;' | grep '^ ${name}$'"
	
	
	if $ensure == 'present' {

    exec { "createuser ${name}":
      command => "${homedir}/bin/psql ${database} -c \"CREATE USER ${$name} PASSWORD ${password}\"",
      user => "${install_owner}",
      unless => "${userexists}",
      require => Service['postgresql'],
    }

  } elsif $ensure == 'absent' {

    exec { "dropuser ${name}":
      command => "${homedir}/bin/dropuser ${name}",
      user => "${install_owner}",
      onlyif => "$userexists",
      require => Service['postgresql'],
      
    }
  }
}
