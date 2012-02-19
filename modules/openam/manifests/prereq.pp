#todo install tomcat as openam tuned instance	
class openam::prereq{
	
	require openam::params
	include tomcat

	tomcat::instance {"${openam::params::tomcat_instance_name}":
  		ensure      => present,
  		server_port => "8005",
  		http_port   => "8080",
  		ajp_port    => "8010",
 		setenv      => [
      			'ADD_JAVA_OPTS="-Xmx1200m -Xms128m"'
    			],
	}
	
	
	
}