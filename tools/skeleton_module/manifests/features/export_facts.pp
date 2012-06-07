define skeleton::features::export_facts(
	$factsdir 	= "/etc/facter/facts.d",
	$options 	=	'',
	$tags		= 	'',
	$setname	=	'skeleton_facts'
){
	
	@@file{"${setname}":
			path 	=> "/etc/facter/facts.d/$name.txt",
			content => template(export_facts.erb),
			require => File["$factsdir"]
	}	
}