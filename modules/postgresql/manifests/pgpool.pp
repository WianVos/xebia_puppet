class postgresql::pgpool(
	$homedir 			= params_lookup("homedir"),
	$install_owner 		= params_lookup("install_owner"),
	$install_group		= params_lookup("install_group"),
	$manage_files		= "present",
	$manage_directory 	= "directory",
	$datadir			= params_lookup("datadir")
	
) {
		exec {
		"add pgpool_reclass" :
			command =>
			"${homedir}/bin/psql -f ${homedir}/share/contrib/pgpool-regclass.sql template1",
			user => "${install_owner}",
			require => [Service['postgresql']],
			creates => "/opt/postgresql/lib/pgpool-regclass.so"
	}
	file {
		"basebackup.sh" :
			path => "${datadir}/basebackup.sh",
			owner => "${install_owner}",
			group => "${install_group}",
			ensure => "${manage_files}",
			require => Exec["initdb ${datadir}"],
			content => template('postgresql/basebackup.sh.erb')
	}
	file {
		"pgpool_remote_start" :
			path => "${datadir}/pgpool_remote_start",
			owner => "${install_owner}",
			group => "${install_group}",
			ensure => "${manage_files}",
			require => Exec["initdb ${datadir}"],
			content => template('postgresql/pgpool_remote_start.erb')
	}
	file {
		["/var/log/pgpool", "/var/log/pgpool/trigger"] :
			ensure => "${manage_directory}",
			owner => "${install_owner}",
			group => "${install_group}",
			require => Exec["initdb ${datadir}"],
	}
	
	}