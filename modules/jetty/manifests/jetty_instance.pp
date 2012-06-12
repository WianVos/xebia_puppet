define jetty::instance (
  $ensure = "present",
  $disabled = false,
  $basedir,
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
	
  #set download_url depening on version
  $download_url ="http://download.eclipse.org/jetty/${version}/dist/jetty-distribution-${version}.tar.gz"
	
  #set the installdir in accordance to the name and the basedir
  $installpath = "${basedir}/${name}"
  
  
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

  user { $runtime_user:
    ensure => $ensure_user,
    gid    => $runtime_user,
  }

  group { $runtime_user:
    ensure => $ensure_group,
  }


  if $ensure != 'absent' {
	
	file{"$installdir":
        	ensure  => directory,
        	owner   => "${runtime_user}",
        	group   => "${runtime_user}",
        	require => [User["$runtime_user"],Group["$runtime_user"]]
  		}

	 case $install {
		'files':	{ file {"${name}_jetty-${version}.zip":
               		    	ensure => $manage_files,
               		   	 	path => "/var/tmp/jetty-${version}.zip",
           					require => User['$runtime_user'],
           					source => "puppet:///modules/jetty/jetty-${version}.zip",
           					before => Exec["unpack jetty"]
        				}
	
    				  exec{"${name}_unpack_jetty":
       		         		command         => "/usr/bin/unzip /var/tmp/jetty-${version}.zip",
       		         		cwd             => "${installdir}",
       		         		creates         => "${installdir}/bin",
       		         		require         => File["${installdir}","jetty-${version}.zip"],
       		         		user            => "${runtime_user}",
       		         		}
					}
		'source':	{ xebia_common::source{"${name}_unpack_jetty":
       		         		source_url      =>  "${download_url}",
       		 				target          =>      "${installdir}",
       		         		type            =>      "targz",
       		         		owner           =>      "${runtime_user}",
       		         		group           =>      "${runtime_user}",
							require		=> [User['$runtime_user'],File["${installdir}"]]
							}
        			}
		default :	{ notice("unsupported install method entered") }
	}


    	File {
    	  ensure 	=> present,
	  require 	=> $install ?{
			'files' 	=> Exec["unpack_jetty"],
			'source' 	=> Xebia_common::Source["unpack_jetty"],
			default 	=> Xebia_common::Source["unpack_jetty"],
			},
	  owner		=> "${runtime_user}",
	  group		=> "${runtime_user}",
   	 }

    	file {["${installdir}/webapps",
             "${installdir}/contexts",
             "${installdir}/resources",
             "${installdir}/etc" ]:
      	     ensure  => directory,
      	     mode    => 2775,
    	}
    	
	# Static files
    	file {
      		"${installdir}/etc/jetty-resources.xml":
      		  source  => 'puppet:///modules/jetty/jetty-resources.xml',
       		  replace => no;

      		"${installdir}/etc/jetty-jndi.xml":
        	  source  => 'puppet:///modules/jetty/jetty-jndi.xml';
        }

    	# Templates
        file {
      		"${installdir}/etc/jetty-logging.xml":
        	  content => template('jetty/jetty-logging.xml.erb');

      		"${installdir}/etc/jetty.xml":
        	   content => template('jetty/jetty.xml.erb');

      		"${installdir}/etc/logback-access.xml":
       		   content => template('jetty/logback-access.xml.erb'),
        	   mode    => 0644;

      		"${installdir}/bin/start.sh":
        	  content => template('jetty/start.sh.erb'),
        	  mode    => 0755;

      		"${installdir}/bin/status.sh":
        	  content => template('jetty/status.sh.erb'),
        	  mode    => 0755;

      		"${installdir}/bin/stop.sh":
        	  content => template('jetty/stop.sh.erb'),
        	  mode    => 0755;

      		"${installdir}/start.ini":
        	  content => template('jetty/start.ini.erb'),
        	  mode    => 0644;
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
        start      => "${installdir}/server/start.sh > /dev/null 2>&1",
        stop       => "${installdir}/server/stop.sh > /dev/null 2>&1",
        status     => "ps -fU ${name} | grep jetty > /dev/null 2>&1",
       }
 }else{

    service { "${installdir}/server/bin/jetty":
        ensure     => "stopped",
        hasstatus  => false,
        hasrestart => false,
        start      => "${installdir}/server/start.sh > /dev/null 2>&1",
        stop       => "${installdir}/server/stop.sh > /dev/null 2>&1",
        status     => "ps -fU ${name} | grep jetty > /dev/null 2>&1",
    		}
    file{"$installdir":
   	ensure  => directory,
        owner   => "${runtime_user}",
        group   => "${runtime_user}",
        require => Service["${installdir}/server/bin/jetty"]
        }	
  } #if

} #define
