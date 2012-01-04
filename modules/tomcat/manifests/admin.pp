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
class tomcat::admin {
	
  include tomcat::params

  user{"tomcat":
    ensure => present,
    require => Group["tomcat user group"],
    uid    => $tomcat::params::tomcat_user_uid? {
      ''      => undef,
      default => $tomcat::params::tomcat_user_uid,
    },
    gid => $tomcat::params::tomcat_user_group? {
      ''      => undef,
      default => $tomcat::params::tomcat_user_group,
    }
  }
  
  group{"tomcat user group":
	name => "${tomcat::params::tomcat_user_group}",
    	ensure => present,
    	gid    => $tomcat::params::tomcat_user_uid? {
      	''      => undef,
      	default => $tomcat::params::tomcat_user_uid,
    	}
 }

}
