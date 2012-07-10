define deployit::imports::export_jetty(
	$instance_name ,
	$homedir,
	$timestamp	=  inline_template("<%= Time.now.strftime('%Y-%m-%dT%H:%M:%S%z') %>"),
	$maxage 	=  "28800",
	$customer	=  "xx",
	$application 	=  "xx",
	$universe	=  "xx",
	$hostname	=  "${::hostname}",
	$environments 	=  "${::environment}",
	$fqdn 		=  "${::fqdn}"
		
){
	notify {
                "export_db $name" :
        }

	#initialize a variables on the importing side	
	$local_universe  = params_lookup("universe", global)
	
	# check age of facts ..
	$age = inline_template("<%= require 'time'; Time.now - Time.parse(timestamp) %>")
	
	if ("${age}" < "${maxage}") {
		$ensure_age = true
		notify{"${name} age: ${age} timestamp: ${timestamp} too old ":} 
	}
	if ($universe == params_lookup("universe", global)) {
		$ensure_universe = true
		 notify{"${name} universe: ${local_universe} imported_universe: ${universe} wrong universe ":}
	}
	
	if (($ensure_age == true) and ($ensure_universe == true)) {
		
		deployit::types::jetty_ssh {
			"${instance_name}" :
				environments 	=> "general",
				homedir	        => "${homedir}",
				instance_name 	=> "${instance_name}",
				application	=> "${application}",
				customer	=> "${customer}",
		} 
	}
	
}
