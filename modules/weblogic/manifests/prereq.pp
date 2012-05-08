class weblogic::prereq{
	
	file{"/var/tmp/weblogic_config":
		recurse => true,
		ensure => present
	}
	
	common::nfs_share{"/var/tmp/weblogic_config":
		hosts => "*",
		path => "/var/tmp/weblogic_config"
	}
	
	File{owner => root, group => root, }
	file {"${weblogic::params::data_dir}":
		ensure => directory,
		}
	file {"${weblogic::params::domain_base_dir}":
		ensure => directory,
		}
	file {"${weblogic::params::log_base_dir}":
		ensure => directory,
		}
	file {"${weblogic::params::application_base_dir}":
		ensure => directory,
		}
}