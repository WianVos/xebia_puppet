/*
tomcat::install

Basic installation for tomcat 

TODO:
	source install
	logging
	extra adapters
*/

class tomcat::ubuntu::install {
 	# include basics
	include tomcat::params

	# download and install source

	common::source {"${tomcat::params::tomcat_archive_filename}":
                        source_url => "${tomcat::params::tomcat_src_url}",
                        target => "/opt",
			type => "targz"
                }

	
	# setup links 

	 file {"/opt/apache-tomcat":
    		ensure  => link,
    		target  => "${tomcat::params::tomcat_home}",
    		require => Common::Source["${tomcat::params::tomcat_archive_filename}"],
  		}	
			
	
}
