define deployit_cli::types::jetty_ssh(
	$hostname		= "${::hostname}",
	$environments	= "general"
){
	deployit_cli::types::overthere_ssh{"${hostname} jetty overthere_ssh":
		hostname 		=> ${::hostname},
		environments	=> "${environments}"
	}
}