define jetty::auto::deployit (
	$instanceName,
	$application,
	$homedir,
	$customer = params_lookup("customer", 'global'),
	$universe = params_lookup("universe", 'global'),
	$environments = "general"
) {
	
	Deployit::Exports::Create_deployit_user <<| |>>
	
	@@deployit::imports::export_jetty {
		"${::hostname}-${::instanceName}" :
			instanceName => "${instanceName}",
			customer => "${customer}",
			application => "${application}",
			universe => "${universe}",
			homedir => "${homedir}",
			environments => "${::environment}",
			fqdn => "${::fqdn}"
	}
	
}