define jetty::config (
  $ensure,
  $port,
  $installdir,
  $runtime_user,
  $java_home,
  $initial_heap,
  $max_heap,
  $min_threads,
  $max_threads,
  $db2_libs,
  $mq_libs,
  $activemq_libs,
  $accesslog
){

  if $ensure != absent {

    file { [ "${installdir}/webapps",
             "${installdir}/contexts",
             "${installdir}/resources",
             "${installdir}/etc" ]:
      ensure  => directory,
      mode    => 2775,
    }

    File {
      ensure => present,
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

  } #if

} #define
