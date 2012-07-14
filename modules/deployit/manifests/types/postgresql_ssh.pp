define deployit::types::postgresql_ssh (
	$db_name        ,
	$environments 	= "${::environment}",
	$remotefqdn  	= "",
	$customer       = undef,
	$application	= undef,
	$postgresql_home = "/opt/postgresql",
	$db_username	= "",
	$db_password	= "",
	$remotehost		= ""
	){
	
	
	
	case $customer {
		undef : {
			if $application == undef {
				if $stage == undef {
					$ciEnv = "Environments/${environments}"
				}
				else {
					$ciEnv = "Environments/${stage}"
				}
			}
			else {
				if $stage == undef {
					$ciEnv = "Environments/${application}"
				}
				else {
					if !defined(Deployit::Features::Ci["${application} directory"]) {
						deployit::features::ci {
							"${application} directory" :
								ciId => "Environments/${application}",
								ciType => 'core.Directory',
								ciValues => {name => "${application}"},
								ensure => present
						}
					}
					$ciEnv = "Environments/${application}/${stage}"
				}
			}
		}
		default : {
			if !defined(Deployit::Features::Ci["${customer} directory"]) {
				deployit::features::ci {
					"${customer} directory" :
						ciId => "Environments/${customer}",
						ciType => 'core.Directory',
						ciValues => {name => "${customer}"},
						ensure => present
				}
			}
			if $application == undef {
				if $stage == undef {
					$ciEnv = "Environments/${customer}/default"
				}
				else {
					if !defined(Deployit::Features::Ci["${customer} default directory"]) {
						deployit::features::ci {
							"${customer} default directory" :
								ciId => "Environments/${customer}/default",
								ciType => 'core.Directory',
								ciValues => {name => "default"},
								ensure => present
						}
						$ciEnv = "Environments/${customer}/default/${stage}"
					}
				}
			}
			else {
				if $stage == undef {
					$ciEnv = "Environments/${customer}/${application}"
				}
				else {
					if
					!defined(Deployit::Features::Ci["${customer} ${application} directory"]) {
						deployit::features::ci {
							"${customer} ${application} directory" :
								ciId => "Environments/${customer}/${application}",
								ciType => 'core.Directory',
								ciValues => {name => "${application}"},
								ensure => present
						}
						$ciEnv = "Environments/${customer}/${application}/${stage}"
					}
				}
			}
		}
	
	
	if ! defined(Deployit::Features::Ci["${remotehost}-ssh-host"]){
		deployit::features::ci{ "${remotehost}-ssh-host":
 				 ciId => "Infrastructure/${remotehost}",
  				 ciType => 'overthere.SshHost',
  				 ciValues => { os => UNIX, connectionType => SUDO, username => 'deployit', password => 'deployit',
                 sudoUsername => 'root', address => "${remotefqdn}", privateKeyFile => "/opt/deployit/keys/jetty_id_rsa" },
                 ciEnvironments => "${ciEnv}",
  				 ensure => present,
		}
	}
	
	if ! defined(Deployit::Features::Ci["postgresql_database_${db_name}"]) {	
		deployit::features::ci {
			"postgresql_database_${db_name} " :
				ciId => "Infrastructure/${remotehost}/${db_name}",
				ciType => 'sql.PostgreSqlClient',
				ciValues => { postgresqlHome => "$postgresql_home", databaseName => "${db_name}", username => "${db_username}", password => "${db_password}"},
				ciEnvironments => "${ciEnv}",
				require =>
				Deployit::Features::Ci["${remotehost}-ssh-host"],
				ensure => present,
		}
	}
}
