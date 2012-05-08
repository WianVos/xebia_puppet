class weblogic::admin_server(
	$domain_name = "$::domain_name"
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
		source => "puppet:///modules/weblogic/admin_server/domain_utility.py",
		require => File["${weblogic::params::infradir}/weblogic"]
		}
	file {"${weblogic::params::infradir}/weblogic/schemes.py":
		source => "puppet:///modules/weblogic/admin_server/schemes.py",
		require => File["${weblogic::params::infradir}/weblogic"]
		}
	file {"${weblogic::params::infradir}/weblogic/weblogic.py":
		source => "puppet:///modules/weblogic/admin_server/weblogic.py",
		require => File["${weblogic::params::infradir}/weblogic"]
		}
	file {"${weblogic::params::infradir}/weblogic/${domain_name}.py":
		content => template('weblogic/admin_server/environment_template.py.erb'),
		require => File["${weblogic::params::infradir}/weblogic"]
		}
	file {"${weblogic::params::infradir}/weblogic/weblogic_template.py":
		content => template('weblogic/admin_server/weblogic_template.py.erb'),
		require => File["${weblogic::params::infradir}/weblogic"]
		}
	
	exec{"${domain_name} domain creation":
		command => "${weblogic::params::installpath}/wlserver_10.3/common/bin/wlst.sh -i weblogic.py -p ${domain_name}",
		cwd => "${weblogic::params::infradir}/weblogic",
		creates => "${weblogic::params::application_base_dir}/${domain_name}",
		require => File["${weblogic::params::infradir}/weblogic/domain_utility.py","${weblogic::params::infradir}/weblogic/schemes.py","${weblogic::params::infradir}/weblogic/weblogic.py","${weblogic::params::infradir}/weblogic/${domain_name}.py","${weblogic::params::infradir}/weblogic/weblogic_template.py"  ]
		}
	
}