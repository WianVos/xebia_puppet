define deployit_cli::types::jetty_ssh ($hostname = "${::hostname}",
	$environments = "${::environment}",
	$fqdn = "${::fqdn}",
	$homedir = "/opt/jetty",
	$instanceName = "default_jetty",
	$customer = undef,
	$application = undef
	){
	
	
	case $customer {
		undef : {
			if $application != undef {
				$ciEnv = "Environments/${environments}"
			}
			else {
				$ciEnv = "Environments/${environments}/${application}"
			}
		}
		default : {
			if $application != undef {
				$ciEnv = "Environments/${environments}/${customer}"
			}
			else {
				$ciEnv = "Environments/${environments}/${customer}/${application}"
			}
		}
	}
	
	if ! defined(Deployit_cli::Types::Overthere_ssh["${hostname} jetty overthere_ssh"]){
		deployit_cli::types::overthere_ssh {
			"${hostname} jetty overthere_ssh" :
				hostname 	 => "${::hostname}",
				environments => "${ciEnv}",
				fqdn 		 => "${fqdn}"
		}
	}
	
	deployit_cli::features::ci {
		"jetty_server_${hostname}_${instanceName} " :
			ciId 			=> "Infrastructure/${hostname}/${instanceName}",
			ciType 			=> 'jetty.Server',
			ciValues 		=> {home => "$homedir", startScript => "${homedir}/start.sh",
			stopScript 		=> "${homedir}/bin/stop.sh"},
			ciEnvironments 	=> "${ciEnv}",
			require 		=> Deployit_cli::Types::Overthere_ssh["${hostname} jetty overthere_ssh"],
			ensure 			=> present,
	}
}