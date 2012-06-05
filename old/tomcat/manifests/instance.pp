/*


*/
define tomcat::instance($ensure="present",
                        $owner="tomcat",
                        $group="tomcat",
                        $server_port="8005",
                        $http_port="8080",
                        $http_address=false,
                        $ajp_port="8009",
                        $ajp_address=false,
                        $conf_mode="",
                        $server_xml_file="",
                        $webapp_mode="",
                        $java_home="",
                        $sample=undef,
                        $setenv=[],
                        $connector=[],
                        $executor=[],
                        $authentication=[],
                        $manage=false) {

  include tomcat::params
  
  $tomcat_name = $name
  $basedir = "${tomcat::params::tomcat_instance_base}/${name}"
  $serverdotxml = "server.xml.tomcat6.erb"
  $catalinahome = "/opt/apache-tomcat"
  $javahome = "${tomcat::params::java_home}"

  if $owner == "tomcat" {
    $dirmode  = $webapp_mode ? {
      ""      => 2770,
      default => $webapp_mode,
    }
    $filemode = 0460
    $confmode = $conf_mode ? {
      ""      => 2570,
      default => $conf_mode
    }

  } else {
    $dirmode  = $webapp_mode ? {
      ""      => 2775,
      default => $webapp_mode,
    }
    $filemode = 0664
    $confmode = $conf_mode ? {
      ""      => $dirmode,
      default => $conf_mode
    }
  }

  if $connector == [] and $server_xml_file == "" {
    
    $connectors = ["http-${http_port}-${name}","ajp-${ajp_port}-${name}"]
    
    tomcat::connector{"http-${http_port}-${name}":
      ensure   => $ensure ? {
        "absent" => absent,
        default  => present,
      },
      instance => $name,
      protocol => "HTTP/1.1",
      port     => $http_port,
      manage   => $manage,
      address  => $http_address,
      group    => $group,
      owner    => $owner
    }

    tomcat::connector{"ajp-${ajp_port}-${name}":
      ensure   => $ensure ? {
        "absent" => absent,
        default  => present,
      },
      instance => $name,
      protocol => "AJP/1.3",
      port     => $ajp_port,
      manage   => $manage,
      address  => $ajp_address,
      group    => $group,
      owner    => $owner
    }

  } else {
    $connectors = $connector
  }

  if defined(File["${tomcat::params::tomcat_instance_base}"]) {
    debug "File[${tomcat::params::tomcat_instance_base}] already defined"
  } else {
    file {"${tomcat::params::tomcat_instance_base}":
      ensure => directory,
    }
  }

    
  

  # Instance directories
  case $ensure {
    present,installed,running,stopped: {
      file {
        # Nobody usually write there
        "${basedir}":
          ensure => directory,
          owner  => $owner,
          group  => $group,
          mode   => 0555,
          before => Service["tomcat-${name}"],
          require => $group ? {
            "adm"   => undef,
            default => Group[$group],
          };
    
        "${basedir}/bin":
          ensure => directory,
          owner  => "root",
          group  => $group,
          mode   => 755,
          before => Service["tomcat-${name}"];
    
        # Developpers usually write there
        "${basedir}/conf":
          ensure => directory,
          owner  => $owner,
          group  => $group,
          mode   => $confmode,
          before => Service["tomcat-${name}"];

        "${basedir}/lib":
          ensure => directory,
          owner  => "root",
          group  => $group,
          mode   => 2775,
          before => Service["tomcat-${name}"];

        "${basedir}/private":
          ensure => directory,
          owner  => "root",
          group  => $group,
          mode   => 2775,
          before => Service["tomcat-${name}"];

        "${basedir}/conf/server.xml":
          ensure  => present,
          owner   => $owner,
          group   => $group,
          mode    => $filemode,
          source  => $server_xml_file? {
            ""      => undef,
            default => $server_xml_file,
          },
          content => $server_xml_file? {
            ""      => template("tomcat/${serverdotxml}"),
            default => undef,
          },
          before  => Service["tomcat-${name}"],
          notify  => $manage? {
            true    => Service["tomcat-${name}"],
            default => undef,
          }, 
          require => $server_xml_file? {
            ""      => undef,
            default => Tomcat::Connector[$connectors],
          },
          replace => $manage;

        "${basedir}/conf/web.xml":
          ensure  => present,
          owner   => $owner,
          group   => $group,
          mode    => $filemode,
          content => template("tomcat/web.xml.erb"),
          before  => Service["tomcat-${name}"],
          notify  => $manage? {
            true    => Service["tomcat-${name}"],
            default => undef,
          },
          replace => $manage;

        "${basedir}/README":
          ensure  => present,
          owner   => "root",
          group   => "root",
          mode    => 644,
          content => template("tomcat/README.erb");

        "${basedir}/webapps":
          ensure => directory,
          owner  => $owner,
          group  => $group,
          mode   => $dirmode,
          before => Service["tomcat-${name}"];
    
        # Tomcat usually write there
        "${basedir}/logs":
          ensure => directory,
          owner  => "tomcat",
          group  => $group,
          mode   => 2770,
          before => Service["tomcat-${name}"];
        "${basedir}/work":
          ensure => directory,
          owner  => "tomcat",
          group  => $group,
          mode   => 2770,
          before => Service["tomcat-${name}"];
        "${basedir}/temp":
          ensure => directory,
          owner  => "tomcat",
          group  => $group,
          mode   => 2770,
          before => Service["tomcat-${name}"];
      }

    }
    absent: {
      file {$basedir:
        ensure  => absent,
        recurse => true,
        force   => true,
      }
    }
  }

  $present = $ensure ? {
    present   => "present",
    installed => "present",
    running   => "present",
    stopped   => "present",
    absent    => "absent",
  }


  # Default JVM options
  file {"${basedir}/bin/setenv.sh":
    ensure  => $present,
    content => template("tomcat/setenv.sh.erb"),
    owner  => "root",
    group  => $group,
    mode   => 754,
    before => Service["tomcat-${name}"],
  }

  # User customized JVM options
  file {"${basedir}/bin/setenv-local.sh":
    ensure  => $present,
    replace => false,
    content => template("tomcat/setenv-local.sh.erb"),
    owner  => "root",
    group  => $group,
    mode   => 574,
    before => Service["tomcat-${name}"],
  }


  # Init and env scripts
  file {"/etc/init.d/tomcat-${name}":
    ensure  => $present,
    content => template("tomcat/tomcat.init.erb"),
    owner   => "root",
    mode    => "755",
    require => File["${basedir}/bin/setenv.sh"],
  }

  
    $servicerequire = File["/opt/apache-tomcat"]
  

  service {"tomcat-${name}":
    ensure  => $ensure ? {
      present   => "running",
      running   => "running",
      stopped   => "stopped",
      installed => undef,
      absent    => "stopped",
      default	=> "running",
    },
    enable  => $ensure ? {
      present   => true,
      running   => true,
      stopped   => false,
      installed => false,
      absent    => false,
      default 	=> true,
    },
    require => [File["/etc/init.d/tomcat-${name}"], $servicerequire],
    pattern => "-Dcatalina.base=${tomcat::params::tomcat_instance_base}/${name}",
  }

  # Logrotate
  file {"/etc/logrotate.d/tomcat-${name}.conf":
    ensure => absent,
  }
}
