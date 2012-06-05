class deployit::features::expconn(
	$configdir = '/etc/xebia_puppet/etc'
	
){
	@@file{"deployit_facts":
			path 	=> "/etc/facter/facts.d/facts_deployit.txt",
			content => template(facts_deployit.txt.erb),
			require => File["/etc/facter/facts.d"]
	}
}