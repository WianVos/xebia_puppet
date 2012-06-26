define postgresql::user(
	$install_owner = params_lookup('install_owner'),
	$ensure	= params_lookup('ensure'),
	$user_params = "--no-superuser --no-createdb --no-createrole"
){
	$userexists = "psql --tuples-only -c 'SELECT rolname FROM pg_catalog.pg_roles;' | grep '^ ${name}$'"
	
	
	if $ensure == 'present' {

    exec { "createuser ${name}":
      command => "createuser ${user_params} ${name}",
      user => "${install_owner}",
      unless => "${userexists}",
      require => Class['postgresql'],
    }

  } elsif $ensure == 'absent' {

    exec { "dropuser ${name}":
      command => "dropuser ${name}",
      user => "${install_owner}",
      onlyif => "$userexists",
    }
  }
}