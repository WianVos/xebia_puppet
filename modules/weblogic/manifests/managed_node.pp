class weblogic::managed_node(
	$admin_server = ""
){
	include weblogic::params
	include weblogic::prereq
	class{"weblogic::install":
		require => Class["weblogic::prereq"]
	}
	
	
}