define jetty_instance(
  $download_url,
  $ensure        = 'present',
  $port          = '8080',
  $installdir    = "/opt/jetty/${name}",
  $java_home     = '/usr/java',
  $initial_heap  = '64',
  $max_heap      = '128',
  $min_threads   = '10',
  $max_threads   = '200',
  $db2_libs      = false,
  $mq_libs       = false,
  $activemq_libs = false,
  $accesslog     = true,
  $runtime_user  = $name,
  $appname       = "default",
  $customer	 = "default",
  
) {

  if ! ( $ensure in [ 'present', 'absent', 'stopped' ] ) {
    fail ('Invalid value of ensure')
  }

  if $ensure != absent {
    Jetty::Install[ $appname ] ->
    Jetty::Config[ $appname ]
  } else {
    Jetty::Config[ $appname ] ->
    Jetty::Install[ $appname ]
  }

  jetty::install{ $appname:
    ensure       => $ensure,
    installdir   => $installdir,
    download_url => $download_url,
    runtime_user => $runtime_user,
  }

  jetty::config{ $appname:
    ensure        => $ensure,
    installdir    => $installdir,
    runtime_user  => $runtime_user,
    port          => $port,
    java_home     => $java_home,
    initial_heap  => $initial_heap,
    max_heap      => $max_heap,
    min_threads   => $min_threads,
    max_threads   => $max_threads,
    db2_libs      => $db2_libs,
    mq_libs       => $mq_libs,
    activemq_libs => $activemq_libs,
    accesslog     => $accesslog
  }
}
