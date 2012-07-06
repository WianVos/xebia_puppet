define deployit::types::overthere_ssh(
	$hostname		= "${::hostname}",
	$environments	= "${::environments}",
	$fqdn			= "${::fqdn}"
){
	
	deployit::features::ci{ "${hostname} ssh-host":
 				 ciId => "Infrastructure/${hostname}",
  				 ciType => 'overthere.SshHost',
  				 ciValues => { os => UNIX, connectionType => SUDO, username => 'deployit', password => 'deployit',
                 sudoUsername => 'root', address => "${fqdn}" },
                 ciEnvironments => "Environments/${environments}",
  				 ensure => present,
	}
}


