define deployit_cli::types::overthere_ssh(
	$hostname		= "${::hostname}",
	$environments	= "general"
){
	deployit_cli::features::ci{ "${hostname} ssh-host":
 				 ciId => "Infrastructure/webserver-$::ipaddress_eth1",
  				 ciType => 'overthere.SshHost',
  				 ciValues => { os => UNIX, connectionType => SUDO, username => 'deployit', password => 'deployit',
                 sudoUsername => 'root', address => "${hostname}" },
  				 ensure => present,
	}
}


