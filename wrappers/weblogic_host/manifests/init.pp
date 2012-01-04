class weblogic_host{
	include jrockit

	class{"weblogic":
			require => Class["jrockit"],
		}


}
