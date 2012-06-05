class tomcat::ubuntu::extra{

	include tomcat::params
	
	#create extras dir


	#download source

	common::source{"tomcat-juli.jar":
			source_url => "${tomcat::params::tomcat_extra_url}/${name}",
			target => "${tomcat::params::tomcat_home}/extras",
			type => "regfile",
			}

	file { "${tomcat::params::tomcat_home}/lib/tomcat-juli.jar":
    			ensure  => link,
    			target  => "${tomcat::params::tomcat_home}/extras/tomcat-juli.jar",
    			require => Common::Source["tomcat-juli.jar"],
  		}	

	common::source{"tomcat-juli-adapters.jar":
			source_url => "${tomcat::params::tomcat_extra_url}/${name}",
			target => "${tomcat::params::tomcat_home}/extras",
			type => "regfile",
			}
	file { "${tomcat::params::tomcat_home}/lib/tomcat-juli-adapters.jar":
    			ensure  => link,
    			target  => "${tomcat::params::tomcat_home}/extras/tomcat-juli-adapters.jar",
    			require => Common::Source["tomcat-juli-adapters.jar"],
  		}	

}
