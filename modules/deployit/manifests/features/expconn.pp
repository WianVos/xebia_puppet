class deployit::features::expconn(
	$configdir = '/etc/xebia_puppet/etc'
	
){
	@@file{"deployit_facts":
			path 	=> "/etc/fact.d/facts_deployit.txt",
			content => template(facts_deployit.txt.erb),
			require => File["/etc/facts.d"]
	}
}