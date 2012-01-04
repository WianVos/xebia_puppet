include tomcat 
tomcat::executor {"default":
    ensure            => present,
    instance          => "tomcat2",
    max_threads       => 150,
    min_spare_threads => 25,
  }

  tomcat::connector {"http-8080":
    ensure   => present,
    instance => "tomcat2",
    owner    => "root",
    protocol => "HTTP/1.1",
    port     => 8080,
    executor => "default",
    manage   => true,
  }

  tomcat::instance { "tomcat2":
    ensure    => present,
    manage    => true,
    executor  => ["default"],
    connector => ["http-8080"],
}

tomcat::executor {"default1":
    ensure            => present,
    instance          => "tomcat1",
    max_threads       => 150,
    min_spare_threads => 25,
  }

  tomcat::connector {"http-8090":
    ensure   => present,
    instance => "tomcat1",
    owner    => "root",
    protocol => "HTTP/1.1",
    port     => 8090,
    executor => "default1",
    manage   => true,
  }

  tomcat::instance { "tomcat1":
    ensure    => present,
    manage    => true,
    executor  => ["default1"],
    connector => ["http-8090"],
}
