class weblogic::admin_server(
	$domain_name = ""
){
	include weblogic::params
	include weblogic::prereq
	class{"weblogic::install":
		require => Class["weblogic::prereq"]
	}
	
	
}