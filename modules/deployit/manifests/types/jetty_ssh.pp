define deployit::types::jetty_ssh ($remotehost, 
	$homedir	,
	$instance_name ,
	$environments 	= "${::environment}",
	$remotefqdn 	= "",
	$customer		= undef,
	$application	= undef,
	$remotehost	= "",
	$appstage			= undef
	){
	
	case $customer {
		undef : {
			if $application == undef {
				if $appstage == undef {
					$ciEnv = "Environments/${environments}"
				}
				else {
					$ciEnv = "Environments/${appstage}"
				}
			}
			else {
				if $appstage == undef {
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
					$ciEnv = "Environments/${application}/${appstage}"
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
				if $appstage == undef {
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
						$ciEnv = "Environments/${customer}/default/${appstage}"
					}
				}
			}
			else {
				if $appstage == undef {
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
						$ciEnv = "Environments/${customer}/${application}/${appstage}"
					}
				}
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
