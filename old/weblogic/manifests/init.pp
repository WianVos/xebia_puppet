#testing 123
class weblogic {
	include weblogic::params
	include weblogic::prereq
	class{"weblogic::install":
		require => Class["weblogic::prereq"]
	}
}
