 include tomcat
 include tomcat::admin

  tomcat::instance { "foo":
    ensure => present,
  }

  tomcat::instance { "bar":
    ensure      => present,
    server_port => 8006,
    http_port   => 8081,
    ajp_port    => 8010,
    sample      => true,
    setenv      => [
      'JAVA_XMX="1200m"',
      'ADD_JAVA_OPTS="-Xms128m"'
    ],
  }
