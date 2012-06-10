define deployit_cli::types::jetty_ssh(
	$hostname		= "${::hostname}",
	$environments	= "general",
	$fqdn			= "${::fqdn}"
){
	
	
	deployit_cli::types::overthere_ssh{"${hostname} jetty overthere_ssh":
		hostname 		=> "${::hostname}",
		environments	=> "${environments}",
		fqdn			=> "${fqdn}"
	}
}