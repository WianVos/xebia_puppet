class jenkins::config(
	
){

	concat {
		"${jenkins::jenkins_config}" :
			owner => "${jenkins::install_owner}",
			group => "${jenkins::install_group}",
			notify => Service['jenkins'],
			require => Class["jenkins::install"],
			mode => "0770"
	}
	concat::fragment {
		"jenkins_config_start" :
			content => template('jenkins/config_start.xml.erb'),
			order => 01,
			target => "${jenkins::jenkins_config}"
	}
	concat::fragment {
		"jenkins_config_end" :
			content => template('jenkins/config_end.xml.erb'),
			order => 99,
			target => "${jenkins::jenkins_config}"
	}
}