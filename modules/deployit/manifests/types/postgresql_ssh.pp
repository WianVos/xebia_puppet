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
				$ciEnv = "Environments/${environments}"
			}
			else {
				$ciEnv = "Environments/${application}"
			}
		}
		default : {
			if $application == undef {
				$ciEnv = "Environments/${customer}"
			}
			else {
				$ciEnv = "Environments/${customer}-${application}"
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
