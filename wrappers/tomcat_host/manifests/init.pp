class tomcat_host(customer="benito",
		  environment="test"){
	include tomcat

	tomcat::instance {"tomcat":
  		ensure      => present,
  		server_port => "8005",
  		http_port   => "8080",
  		ajp_port    => "8010",
 		setenv      => [
      			'ADD_JAVA_OPTS="-Xmx1200m -Xms128m"'
    			],
	}
}
