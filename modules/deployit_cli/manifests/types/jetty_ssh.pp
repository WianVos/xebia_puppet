define deployit_cli::types::jetty_ssh ($hostname = "${::hostname}",
	$homedir	,
	$instanceName ,
	$environments 	= "${::environment}",
	$fqdn 			= "${::fqdn}",
	$customer		= undef,
	$application	= undef
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
	
	if ! defined(Deployit_cli::Features::Ci["${hostname} ssh-host"]){
	deployit_cli::features::ci{ "${hostname} ssh-host":
 				 ciId => "Infrastructure/${hostname}",
  				 ciType => 'overthere.SshHost',
  				 ciValues => { os => UNIX, connectionType => SUDO, username => 'deployit', password => 'deployit',
                 sudoUsername => 'root', address => "${fqdn}", privateKeyFile => "/opt/deployit/keys/jetty_id_rsa" },
                 ciEnvironments => "${ciEnv}",
  				 ensure => present,
		}
	}
	
	deployit_cli::features::ci {
		"jetty_server_${hostname}_${instanceName} " :
			ciId => "Infrastructure/${hostname}/${instanceName}",
			ciType => 'jetty.Server',
			ciValues => {home => "$homedir", startScript => "${homedir}/bin/start.sh",
			stopScript => "${homedir}/bin/stop.sh"},
			ciEnvironments => "${ciEnv}",
			require =>
			Deployit_cli::Features::Ci["${hostname} ssh-host"],
			ensure => present,
	}
}