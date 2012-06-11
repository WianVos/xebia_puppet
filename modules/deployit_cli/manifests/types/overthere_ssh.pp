define deployit_cli::types::overthere_ssh(
	$hostname		= "${::hostname}",
	$environments	= "general",
	$fqdn			= "${::fqdn}"
){
	
	deployit_cli::features::ci{ "${hostname} ssh-host":
 				 ciId => "Infrastructure/${hostname}",
  				 ciType => 'overthere.SshHost',
  				 ciValues => { os => UNIX, connectionType => SUDO, username => 'deployit', password => 'deployit',
                 sudoUsername => 'root', address => "${fqdn}" },
                 ciEnvironments => "Environments/${environments}",
  				 ensure => present,
	}
}


