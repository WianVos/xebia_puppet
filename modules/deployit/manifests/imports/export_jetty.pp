define deployit::imports::export_jetty(
	$instance_name ,
	$homedir,
	$timestamp	=  inline_template("<%= Time.now.strftime('%Y-%m-%dT%H:%M:%S%z') %>"),
	$maxage 	=  "28800",
	$customer	=  "xx",
	$application 	=  "xx",
	$universe	=  "xx",
	$remotehost	=  "",
	$environments 	=  "${::environment}",
	$remotefqdn 		=  ""
		
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
		
	}
	if ("${universe}" == params_lookup("universe", global)) {
		$ensure_universe = true
	}
	
	if (($ensure_age == true) and ($ensure_universe == true)) {
		
		deployit::types::jetty_ssh {
			"${remotehost}-${instance_name}" :
				environments 	=> "general",
				homedir	        => "${homedir}",
				instance_name 	=> "${instance_name}",
				application	=> "${application}",
				customer	=> "${customer}",
				remotehost	=> "${remotehost}",
				remotefqdn	=> "${remotefqdn}"
		} 
	}
	
}
