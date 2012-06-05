class tomcat::ubuntu::logging {

  include tomcat::params

  if ( ! $tomcat::params::tomcat_home ) {
    err('undefined mandatory attribute: $tomcat::params::tomcat_home')
  }

  file {"commons-logging.jar":
    path => "${tomcat::params::tomcat_home}/lib/commons-logging.jar",
    ensure => link,
    target => "/usr/share/java/commons-logging.jar",
  }

  file {"log4j.jar":
    path => "${tomcat::params::tomcat_home}/lib/log4j.jar",
    ensure => link,
    target =>  "/usr/share/java/log4j-1.2.jar",    
  }

  file {"log4j.properties":
    path   =>  "${tomcat::params::tomcat_home}/lib/log4j.properties",
    source => $::log4j_conffile,
 }

}