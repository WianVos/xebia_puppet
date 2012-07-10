define deployit::types::jetty_ssh ($remotehost, 
	$homedir	,
	$instance_name ,
	$environments 	= "${::environment}",
	$remotefqdn 	= "",
	$customer		= undef,
	$application	= undef,
	$remotehost	= ""
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
	
	if ! defined(Deployit::Features::Ci["${remotehost} ssh-host"]){
	deployit::features::ci{ "${remotehost} ssh-host":
 				 ciId => "Infrastructure/${remotehost}",
  				 ciType => 'overthere.SshHost',
  				 ciValues => { os => UNIX, connectionType => SUDO, username => 'deployit', password => 'deployit',
                 		sudoUsername => 'root', address => "${remotefqdn}", privateKeyFile => "/opt/deployit/keys/jetty_id_rsa" },
                 		ciEnvironments => "${ciEnv}",
  				 ensure => present,
		}
	}
	
	deployit::features::ci {
		"jetty_server_${remotehost}_${instance_name} " :
			ciId => "Infrastructure/${remotehost}/${instance_name}",
			ciType => 'jetty.Server',
			ciValues => {home => "$homedir", startScript => "${homedir}/start.sh",
			stopScript => "${homedir}/stop.sh"},
			ciEnvironments => "${ciEnv}",
			require =>
			Deployit::Features::Ci["${remotehost} ssh-host"],
			ensure => present,
	}
}
