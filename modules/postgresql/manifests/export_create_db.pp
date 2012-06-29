define postgresql::export_create_db(
	$timestamp	=	inline_template("<%= Time.now.strftime('%Y-%m-%dT%H:%M:%S%z') %>"),
	$maxage 	= 	"28800",
	$customer	=	"xx",
	$application =  "xx",
	$universe	=	"xx",
	$hostname	=   "${::hostname}",
	$db_owner	= 	"postgresql",
	$datadir	=   "/data"
){
	
	$db_user		= "${customer}-${application}-user"
	$db_password	= "${customer}-${application}-password"
	$db_name		= "${customer}-${application}-db"
	
	# check age of facts ..
	$age = inline_template("<%= require 'time'; Time.now - Time.parse(timestamp) %>")
	
	if $age < $maxage {
		$ensure_age = true
	}
	if ($universe == params_lookup("universe", global)) {
		$ensure_universe = true
	}
	if (($customer == params_lookup("customer", global) or $customer == "xx")) {
		$ensure_customer = true
	}
	
	
	if (($ensure_age == true) and ($ensure_universe == true) and ($ensure_customer	== true) ) {
		if !defined(Postgresql::Database["${customer}-${application}"]) {
			postgresql::database {
				"${customer}-${application}" :
					owner => "${db_owner}"
			}
		}
		if !defined(Postgresql::User["${db_user}"]) {
			postgresql::user {
				"${db_user}" :
					password => "${db_password}",
					database => "${db_name}"
			}
		}
		if !defined(User["${db_user}"]){
			user {"${db_user}":
					ensure => present,
					managehome => true
			}
		}
		
		if !defined(Concat::Fragment["${db_user} pg_hba.conf"]) {
			concat::fragment {
				"${db_user} pg_hba.conf" :
					content => "host    all     ${db_user}        0.0.0.0/0          trust",
					order => 02,
					target => "${datadir}/pg_hba.conf",
			}
		}
	}
}
		
			