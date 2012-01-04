# Class: tomcat
#
# This module manages tomcat
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class tomcat::filesys {
  
  include tomcat::params

  file { "/var/log/tomcat":
    ensure => directory,
    owner  => "${tomcat::params::tomcat_user}",
    group  => "${tomcat::params::tomcat_user_group}"
  }
	
  file { "${tomcat::params::tomcat_instance_base}":
	ensure => directory,
	owner  => "${tomcat::params::tomcat_user}",
    	group  => "${tomcat::params::tomcat_user_group}"
	}

}
