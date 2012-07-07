define deployit::types::postgresql_ssh ($hostname = "${::hostname}",
	$homedir	,
	$db_name        ,			
	$environments 	= "${::environment}",
	$fqdn 	        = "${::fqdn}",
	$customer       = undef,
	$application	= undef,
	$postgresql_home = "/opt/postgresql",
	$db_username	= "${db_name}-user",
	$db_password	= ""
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
	
	if ! defined(Deployit::Features::Ci["${hostname} ssh-host"]){
		deployit::features::ci{ "${hostname} ssh-host":
 				 ciId => "Infrastructure/${hostname}",
  				 ciType => 'overthere.SshHost',
  				 ciValues => { os => UNIX, connectionType => SUDO, username => 'deployit', password => 'deployit',
                 		 sudoUsername => 'root', address => "${fqdn}", privateKeyFile => "/opt/deployit/keys/jetty_id_rsa" },
                 		 ciEnvironments => "${ciEnv}",
  				 ensure => present,
		}
	}
	
	if ! defined(Deployit::Features::Ci["postgresql_database_${db_name}"]) {	
		deployit::features::ci {
			"postgresql_database_${db_name} " :
				ciId => "Infrastructure/${hostname}/${db_name}",
				ciType => 'sql.PostgreSqlClient',
				ciValues => { postgresqlHome => "$homedir", databaseName => "${db_name}", username => "${db_username}", password => "${db_password}"},
				ciEnvironments => "${ciEnv}",
				require =>
				Deployit_cli::Features::Ci["${hostname} ssh-host"],
				ensure => present,
		}
	}
}
