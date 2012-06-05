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
class tomcat::params{

	$default_tomcat_version = "6.0.33"
    
	$tomcat_mirror = "http://archive.apache.org/dist/tomcat/"
	$tomcat_version = "6.0.33"
	$tomcat_major_version = "6"	
	$tomcat_archive_filename = "apache-tomcat-${tomcat_version}.tar.gz"
	$tomcat_src_url = "${tomcat_mirror}/tomcat-${tomcat_major_version}/v${tomcat::params::tomcat_version}/bin/${tomcat::params::tomcat_archive_filename}"
	$tomcat_extra_url = "${tomcat_mirror}/tomcat-${tomcat_major_version}/v${tomcat::params::tomcat_version}/bin/extras"

	$tomcat_user = "tomcat"
	$tomcat_user_uid = "401"
	$tomcat_user_group = "tomcat"

	$tomcat_home = "/opt/apache-tomcat-${tomcat::params::tomcat_version}"
	$tomcat_instance_base = "/srv/tomcat"
	$java_home="/usr/lib/jvm/java-6-openjdk/jre"

/*	
	$instance_basedir = $tomcat_instance_basedir ? {
    		""      => "/srv/tomcat",
    		default => $tomcat_instance_basedir,
  		}	
	 
	if $tomcat_mirror {
    		$mirror = $tomcat_mirror
  			} else {
    		$mirror = "http://archive.apache.org/dist/tomcat/"
  		}
	if $tomcat_version = "" {
		$tomcat_version	= $default_tomcat_version
		}
	
	if versioncmp($tomcat_version, '6.0.0' } >= 0 {
		$tomcat_major_version = "6"
		}
*/
		
}

