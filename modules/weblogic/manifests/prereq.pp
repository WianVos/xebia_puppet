class weblogic::prereq{
	
	file{"/var/tmp/weblogic_config":
		recurse => true,
		ensure => present
	}
	
	common::nfs_share{"/var/tmp/weblogic_config":
		hosts => "*",
		path => "/var/tmp/weblogic_config"
	}
}