define jetty::instance(
  $basedir,
  $ensure = "present",
  $disabled = false,
  $port = "8080",
  $version = "8.1.4.v20120524",
  $runtime_user ="${name}_jetty",
  $install = "source",
  $java_home="/usr/lib/jvm/java-6-openjdk",
  $initial_heap='512',
  $max_heap='1024',
  $min_threads='4',
  $max_threads='32',
  $db2_libs=false,
  $mq_libs=false,
  $activemq_libs=false,
  $accesslog = true,
  $appname = "default_application",
  $customer = "default_customer"
  
) {

  #figuring out the source_dir
  $source_dir="${basedir}/${version}"
  		
  #set the installdir in accordance to the name and the basedir
  $installdir = "${basedir}/${name}"
  
  
  $ensure_user = $ensure ? {
    absent  => absent,
    default => present,
  }

  $ensure_group = $ensure ? {
    absent  => absent,
    default => present,
  }

  $manage_files = $ensure ? {
    absent	=> absent,
    present => present,
    default	=> present
  }
  
 $manage_directory = $ensure ? {
    absent	=> absent,
    present => directory,
    default => present
  }

 $manage_service = $disabled ? {
    true	=> stopped,
    false     	=> running,
    default	=> running 
  }

  user {
  	$runtime_user :
  		ensure => $ensure_user,
  		gid => $runtime_user,
  }
  
  group {
  	$runtime_user :
  		ensure => $ensure_group,
  }
  
  exec {
  	"${name}-clone-basedir" :
  		command =>
  		"/bin/cp -rp ${source_dir} ${installdir} && /bin/chown ${runtime_user}:${runtime_user} && /bin/chmod -R 775 ${installdir} ",
  		logoutput => true,
  		creates => "${installdir}/bin",
  		require => File["${installdir}"]
  }  

File {
	ensure => "${manage_files}",
	owner => "${runtime_user}",
	group => "${runtime_user}",
}

file {
	"${installdir}" :
		ensure => "${manage_directory}",
}
file {
	["${installdir}/webapps", "${installdir}/contexts", "${installdir}/resources",
	"${installdir}/etc"] :
		ensure => directory,
		mode => 2775,
		require => Xebia_common::Source["${name}_unpack_jetty"],
}

# Static files
file {
	"${installdir}/etc/jetty-resources.xml" :
		source => 'puppet:///modules/jetty/jetty-resources.xml',
		require => Xebia_common::Source["${name}_unpack_jetty"],
		replace => no ;

	"${installdir}/etc/jetty-jndi.xml" :
		require => Xebia_common::Source["${name}_unpack_jetty"],
		source => 'puppet:///modules/jetty/jetty-jndi.xml' ;
}

# Templates
file {
	"${installdir}/etc/jetty-logging.xml" :
		require => Xebia_common::Source["${name}_unpack_jetty"],
		content => template('jetty/jetty-logging.xml.erb') ;

	"${installdir}/etc/jetty.xml" :
		require => Xebia_common::Source["${name}_unpack_jetty"],
		content => template('jetty/jetty.xml.erb') ;

	"${installdir}/etc/logback-access.xml" :
		require => Xebia_common::Source["${name}_unpack_jetty"],
		content => template('jetty/logback-access.xml.erb'),
		mode => 0644 ;

	"${installdir}/bin/start.sh" :
		require => Xebia_common::Source["${name}_unpack_jetty"],
		content => template('jetty/start.sh.erb'),
		mode => 0755 ;

	"${installdir}/bin/status.sh" :
		require => Xebia_common::Source["${name}_unpack_jetty"],
		content => template('jetty/status.sh.erb'),
		mode => 0755 ;

	"${installdir}/bin/stop.sh" :
		require => Xebia_common::Source["${name}_unpack_jetty"],
		content => template('jetty/stop.sh.erb'),
		mode => 0755 ;

	"${installdir}/start.ini" :
		require => Xebia_common::Source["${name}_unpack_jetty"],
		content => template('jetty/start.ini.erb'),
		mode => 0644 ;
}

    # Optional files - DB2
    if $db2_libs {
      file { "${installdir}/lib/ext/db2" :
        ensure  => present,
        source  => 'puppet:///jetty/db2',
        recurse => true,
        purge   => true,
      }
    } else {
      file { "${installdir}/lib/ext/db2":
        ensure  => absent,
        recurse => true,
        purge   => true,
        force   => true,
      }
    }

    # Optional files - Websphere MQ
    if $mq_libs {
      file { "${installdir}/lib/ext/mq" :
        ensure  => present,
        source  => 'puppet:///jetty/mq',
        recurse => true,
        purge   => true,
      }
    } else {
      file { "${installdir}/lib/ext/mq":
        ensure  => absent,
        recurse => true,
        purge   => true,
        force   => true,
      }
    }

    # Optional files - Active MQ
    if $activemq_libs {
      file { "${installdir}/lib/ext/activemq" :
        ensure  => present,
        source  => 'puppet:///jetty/activemq',
        recurse => true,
        purge   => true,
      }
    } else {
      file { "${installdir}/lib/ext/activemq":
        ensure  => absent,
        recurse => true,
        purge   => true,
        force   => true,
      }
    }
    
  service { "${installdir}/server/bin/jetty":
        ensure     => "${manage_service}",
        hasstatus  => false,
        hasrestart => false,
		require	   => File["${installdir}/bin/start.sh"],
        start      => "${installdir}/server/start.sh > /dev/null 2>&1",
        stop       => "${installdir}/server/stop.sh > /dev/null 2>&1",
        status     => "ps -fU ${name} | grep jetty > /dev/null 2>&1",
       }
 }      
#}else{
#
#    service { "${installdir}/server/bin/jetty":
#        ensure     => "stopped",
#        hasstatus  => false,
#        hasrestart => false,
#        start      => "${installdir}/server/start.sh > /dev/null 2>&1",
#        stop       => "${installdir}/server/stop.sh > /dev/null 2>&1",
#        status     => "ps -fU ${name} | grep jetty > /dev/null 2>&1",
#    		}
#    file{"$installdir":
#   	ensure  => directory,
#        owner   => "${runtime_user}",
#        group   => "${runtime_user}",
#        require => Service["${installdir}/server/bin/jetty"]
#        }	
 #if

 #define
