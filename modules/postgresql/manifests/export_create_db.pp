define postgresql::export_create_db(
	$timestamp	=	inline_template("<%= Time.now.strftime('%Y-%m-%dT%H:%M:%S%z') %>"),
	$maxage 	= 	"28800",
	$customer	=	"xx",
	$application =  "xx",
	$universe	=	"xx",
	$remotehost	=   "${::hostname}",
	$remotefqdn =   "${::remotefqdn}",
	$datadir	=   "/data"
	){
	notify {
                "export_db $name" :
        }

	#initialize a couple of variables on the importing side	
	$db_user		= "${customer}_${application}_user"
	$db_password	= "${customer}_${application}_password"
	$db_name		= "${customer}-${application}-db"
	$local_universe  = params_lookup("universe", global)
	$local_customer	=  params_lookup("customer", global)
	$db_owner	= params_lookup("install_owner") 	

	# check age of facts ..
	$age = inline_template("<%= require 'time'; Time.now - Time.parse(timestamp) %>")
	
	if ("${age}" < "${maxage}") {
		$ensure_age = true
	}
	if ("${universe}" == params_lookup("universe", global)) {
		$ensure_universe = true
	}
	if (("${customer}" == params_lookup("customer", global) or "${customer}" == "xx")) {
		$ensure_customer = true
	}
	
	
	if (($ensure_age == true) and ($ensure_universe == true) and ($ensure_customer	== true) ) and ( !defined(Postgresql::Database["${customer}-${application}"])) {
		# if the database does not exist create it 
		if ! defined(Postgresql::Database["${customer}-${application}"]) {
			postgresql::database {
				"${customer}-${application}" :
					owner => "${db_owner}"
			}
		}

		#if the user is not defined then create it  	
		if !defined(Postgresql::User["${db_user}"]) {
			postgresql::user {
				"${db_user}" :
					password => "${db_password}",
					database => "${db_name}"
			}
		}
		
		
		if !defined(Concat::Fragment["${db_user} pg_hba.conf"]) {
			concat::fragment {
				"${db_user} pg_hba.conf" :
					content => "host    all     ${db_user}        0.0.0.0/0          trust\n",
					order => 02,
					target => "${datadir}/pg_hba.conf",
			}
		}
		
		if !defined(Deployit::Exports::Create_deployit_user["deployit_user"]){
			
			Deployit::Exports::Create_deployit_user <<| |>>
		
		}
		
		@@deployit::imports::export_postgresql{
			"${hostname}-${db_name}":
				dbname	=> "${db_name}",
				customer => "${customer}",
				application => "${application}",
				universe	=> "${universe}",
				remotehost	=> "${remotehost}",
				remotefqdn	=> "${remotefqdn}",
				db_username	=> "${db_user}",
				db_password => "${db_password}"
		}
	}
}
		
			
