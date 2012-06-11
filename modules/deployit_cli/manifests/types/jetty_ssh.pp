define deployit_cli::types::jetty_ssh(
	$hostname		= "${::hostname}",
	$environments	= "${::environment}",
	$fqdn			= "${::fqdn}"
){
	
	
	deployit_cli::types::overthere_ssh{"${hostname} jetty overthere_ssh":
		hostname 		=> "${::hostname}",
		environments	=> "${environments}",
		fqdn			=> "${fqdn}"
	}
	
	deployit_cli::features::ci{ "jetty_server ${hostname} ":
 				 ciId => "Infrastructure/${hostname}/jetty_server1",
  				 ciType => 'jetty.Server',
  				 ciValues => { home => '/opt/jetty', startScript => '/opt/jetty/bin/jetty.sh start', stopScript => '/opt/jetty/bin/jetty.sh stop'},
                 ciEnvironments => "Environments/${environments}",
  				 ensure => present,
	}
}