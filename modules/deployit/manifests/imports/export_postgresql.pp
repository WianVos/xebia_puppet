define deployit::imports::export_postgresql(
	$dbname ,
	$timestamp	=  inline_template("<%= Time.now.strftime('%Y-%m-%dT%H:%M:%S%z') %>"),
	$maxage 	=  "28800",
	$customer	=  "xx",
	$application 	=  "xx",
	$universe	=  "xx",
	$remotehost	=  "",
	$environments 	=  "${::environment}",
	$remotefqdn  	= "",
	$db_username	= "",
	$db_password	= ""
		
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
	if ("${universe}" == params_lookup("universe", global)) {
		$ensure_universe = true
		 notify{"${name} universe: ${local_universe} imported_universe: ${universe} wrong universe ":}
	}
	
	if (($ensure_age == true) and ($ensure_universe == true)) {
		
		deployit::types::postgresql_ssh {
			"${remotehost}-${dbname}" :
				db_name	=> "${dbname}",
				environments 	=> "general",
				application	=> "${application}",
				customer	=> "${customer}",
				remotehost	=> "${remotehost}",
				db_username => "${db_username}",
				db_password	=> "${db_password}",
				remotefqdn	=> "${remotefqdn}"
				
		} 
	}
	
}
