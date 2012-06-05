class weblogic_admin_host{
	include jrockit
	
	
	class{"weblogic::admin_server":
			require => Class["jrockit"],
		}


}
