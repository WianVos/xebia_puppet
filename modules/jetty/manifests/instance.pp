define jetty::instance(
  $basedir			= params_lookup('basedir'),
  $source_dir 		= "${jetty::params::source_dir}",
  $ensure 			= "present",
  $disabled 		= false,
  $port 			= "8080",
  $version 			= "8.1.4.v20120524",
  $install 			= "source",
  $java_home		= "/usr/lib/jvm/java-6-openjdk",
  $initial_heap		= '512',
  $max_heap			= '1024',
  $min_threads		= '4',
  $max_threads		= '32',
  $db2_libs			= false,
  $mq_libs			= false,
  $activemq_libs	= false,
  $postgresql_libs	= false,
  $accesslog 		= true,
  $universe			= params_lookup('universe', 'global'),
  $application 		= params_lookup('application', global),
  $customer 		= params_lookup('customer', global),
  $auto_db			= false
  
) {

  #figuring out the source_dir
  $download_source_dir="${source_dir}/jetty-distribution-${version}"
  		
  
  
  # set the instancename on disk
  $instance_name="${customer}-${application}-${name}"
  
  #create runtime user
  $runtime_user="${customer}_jetty"
  
  #set the installdir in accordance to the name and the basedir
  $installdir = "${basedir}/${instance_name}"
  
  
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

  if !defined(User["${runtime_user}"]){	
  	user {
  		$runtime_user :
  			ensure => $ensure_user,
  			gid => $runtime_user,
  	}
  }
  
  if !defined(Group["${runtime_user}"]){	
  	group {
  		$runtime_user :
  			ensure => $ensure_group,
  	}
  
  }
  
  exec {
  	"${name}-clone-basedir" :
  		command =>
  		"/bin/cp -rp ${download_source_dir}/*  ${installdir} && /bin/chown -R ${runtime_user}:${runtime_user} ${installdir} && /bin/chmod -R 775 ${installdir} ",
  		logoutput => true,
  		creates => "${installdir}/bin",
  		require => File["${installdir}","jetty-source-${version}"] 
  }  

File {
	ensure => "${manage_files}",
	owner => "${runtime_user}",
	group => "${runtime_user}",
	before => Service["${installdir}/server/bin/jetty"],
	notify => Service["${installdir}/server/bin/jetty"],
	
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
		require => File["${installdir}"],
}

# Static files
file {
	"${installdir}/etc/jetty-resources.xml" :
		require => Exec["${name}-clone-basedir"],
		source => 'puppet:///modules/jetty/jetty-resources.xml',
		replace => no ;

	"${installdir}/etc/jetty-jndi.xml" :
		require => Exec["${name}-clone-basedir"],
		source => 'puppet:///modules/jetty/jetty-jndi.xml' ;
}

# Templates
file {
	"${installdir}/etc/jetty-logging.xml" :
		require => Exec["${name}-clone-basedir"],
		content => template('jetty/jetty-logging.xml.erb') ;

	"${installdir}/etc/jetty.xml" :
		require => Exec["${name}-clone-basedir"],
		content => template('jetty/jetty.xml.erb') ;

	"${installdir}/etc/logback-access.xml" :
		require => Exec["${name}-clone-basedir"],
		content => template('jetty/logback-access.xml.erb'),
		mode => 0644 ;

	"${installdir}/start.sh" :
		require => Exec["${name}-clone-basedir"],
		content => template('jetty/start.sh.erb'),
		mode => 0755 ;

	"${installdir}/bin/status.sh" :
		require => Exec["${name}-clone-basedir"],
		content => template('jetty/status.sh.erb'),
		mode => 0755 ;
	
	"${installdir}/stop.sh" :
		require => Exec["${name}-clone-basedir"],
		content => template('jetty/stop.sh.erb'),
		mode => 0755 ;

	"${installdir}/start.ini" :
		require => Exec["${name}-clone-basedir"],
		content => template('jetty/start.ini.erb'),
		mode => 0644 ;
	"${installdir}/bin/start.sh" :
		require => Exec["${name}-clone-basedir"],
		content => template('jetty/start.sh.erb'),
		mode => 0755 ;
	"${installdir}/bin/stop.sh" :
		require => Exec["${name}-clone-basedir"],
		content => template('jetty/stop.sh.erb'),
		mode => 0755 ;
}

    # Optional files - DB2
    if $db2_libs {
      file { "${installdir}/lib/ext/db2" :
      	require => Exec["${name}-clone-basedir"],
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
      	require => Exec["${name}-clone-basedir"],
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
      	require => Exec["${name}-clone-basedir"],
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
    # Optional files - postgresql
    if $postgresql_libs {
      file { "${installdir}/lib/ext/postgresql" :
      	require => Exec["${name}-clone-basedir"],
        ensure  => present,
        source  => 'puppet:///jetty/postgresql',
        recurse => true,
        purge   => true,
      }
    } else {
      file { "${installdir}/lib/ext/postgresql":
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
        start      => "${installdir}/start.sh > /dev/null 2>&1",
        stop       => "${installdir}/stop.sh > /dev/null 2>&1",
        status     => "ps -fU ${instance_name} | grep jetty > /dev/null 2>&1",
       }
 # deployit intergration
 
 deployit_cli::types::jetty_ssh {
	"${instance_name}" :
		environments 	=> "general",
		homedir	 		=> "${installdir}",
		instanceName 	=> "${instance_name}",
		application		=> "${application}",
		customer		=> "${customer}",
	} 

#if auto_db is true then try to create the database by unsing a function from the postgresql module . 
# this needs a change btw	
 if $auto_db == true {
 	@@postgresql::export_create_db {
 		"${instance_name}" :
 			application => "${application}",
 			customer => "${customer}",
 			universe => "${universe}"
 	}
 }
 }	
    

