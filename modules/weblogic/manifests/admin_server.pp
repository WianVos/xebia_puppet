class weblogic::admin_server(
	$domain_name = ""
){
	include weblogic::params
	include weblogic::prereq
	class{"weblogic::install":
		require => Class["weblogic::prereq"]
	}
	
	File {owner => root, group => root }
	
	file {"${weblogic::params::infradir}":
		ensure => directory,
		}
	file {"${weblogic::params::infradir}/weblogic":
		ensure => directory,
		}
	file {"${weblogic::params::infradir}/weblogic/domain_utility.py":
		source => "puppet:///modules/weblogic/admin_server/domain_utility.py"
		}
	file {"${weblogic::params::infradir}/weblogic/schemes.py":
		source => "puppet:///modules/weblogic/admin_server/schemes.py"
		}
	file {"${weblogic::params::infradir}/weblogic/weblogic.py":
		source => "puppet:///modules/weblogic/admin_server/weblogic.py"
		}
	file {"${weblogic::params::infradir}/weblogic/environment_template.py":
		content => template('weblogic/weblogic-silent.xml.erb'),
		}
}