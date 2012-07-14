define jetty::auto::deployit (
	$instance_name,
	$application,
	$homedir,
	$customer = params_lookup("customer", 'global'),
	$universe = params_lookup("universe", 'global'),
	$appstage    = params_lookup("appstage", global),
	$environments = "general"
) {
	
	Deployit::Exports::Create_deployit_user <<| |>>
	
	@@deployit::imports::export_jetty {
		"${::hostname}-${instance_name}" :
			instance_name => "${instance_name}",
			customer => "${customer}",
			application => "${application}",
			appstage => "${appstage}",
			universe => "${universe}",
			homedir => "${homedir}",
			environments => "${::environment}",
			remotefqdn => "${::fqdn}",
			remotehost => "${::hostname}"
	}
	
}
