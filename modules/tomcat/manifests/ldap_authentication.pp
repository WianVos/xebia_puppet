/*

sample usages

  tomcat::ldap_authentication {"default":
    ensure            => present,
    instance          => "tomcat1",
    connectionUrl	  => ""ldap://localhost:1389",
  }
  tomcat::instance { "tomcat1":
    ensure    => present,
    group     => "tomcat-admin",
    manage    => true,
    executor  => ["default"],
    connector => ["http-8080"]
  }

*/
define tomcat::ldap_authentication($ensure="present",
                        $instance,
                        $owner="tomcat",
                        $group="tomcat",
                        $connectionUrl = "",
       					$userPattern="uid={0},ou=people,dc=example,dc=com",
      					$userRoleName="isMemberOf",
          				$roleBase="ou=groups,dc=example,dc=com",
          				$roleName="cn",
        				$roleSearch="(uniqueMember={0})",
                        $manage=false) {

  include tomcat::params

  if $owner == "tomcat" {
    $filemode = 0460
  } else {
    $filemode = 0664
  }

  file {"${tomcat::params::tomcat_instance_base}/${instance}/conf/ldap_authentication.xml":
    ensure  => $ensure,
    owner   => $owner,
    group   => $group,
    mode    => $filemode,
    content => template("tomcat/ldap_authentication.xml.erb"),
    replace => $manage,
    require => File["${tomcat::params::tomcat_instance_base}/${instance}/conf"],
  }

}
