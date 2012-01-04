class tomcat::ubuntu::base {
	
	include tomcat::params	
	include tomcat::ubuntu::admin
	include tomcat::ubuntu::filesys
	include tomcat::ubuntu::install
	include tomcat::ubuntu::extra
	include tomcat::ubuntu::logging
	include tomcat::ubuntu::packages
	
	Class['tomcat::ubuntu::packages'] -> Class ['tomcat::ubuntu::admin'] -> Class ['tomcat::ubuntu::filesys'] -> Class ['tomcat::ubuntu::install'] -> Class ['tomcat::ubuntu::extra'] -> Class ['tomcat::ubuntu::logging']
	

}
