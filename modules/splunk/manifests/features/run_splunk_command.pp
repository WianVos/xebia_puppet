define splunk_server::features::run_splunk_command (
	$admin_user = params_lookup('admin_user'),
	$admin_password = params_lookup('admin_password'),
	$homedir = params_lookup('homedir'),
	$markerdir = params_lookup('markerdir'),	
	$splunk_command = "",
	$splunk_returns = ["0"],
	$splunk_restart = false
){
	
	
	
	file { "${name} command file":
		path => "/var/tmp/${name}_command.ksh",
		content => template("splunk_server/features/run_splunk_command.ksh.erb"),
		mode => '0550'
	}
	
	
	
	exec { "$name splunk cli":
		path => "${homedir}/bin",
		command => "/var/tmp/${name}_command.ksh",
        before => Exec["${name} splunk restart"],
		require => File["${name} command file"], 
		logoutput => true,
		creates => "${markerdir}/etc/${name}_command_run",
		returns => $splunk_returns 
	}
	
	exec {"${name} splunk restart":
			command => $splunk_restart ? {
							true => "/etc/init.d/splunk restart && touch ${markerdir}/etc/${name}_command_restart ",
							default => "/bin/echo"
						},
			creates => "${markerdir}/etc/${name}_command_restart",
	}
}
