define jetty::service ( $homedir, $ensure ){

	service { "${homedir}/server/bin/jetty":
		ensure     => "${ensure}",
		hasstatus  => false,
		hasrestart => false,
		start      => "${homedir}/server/start.sh > /dev/null 2>&1",
		stop       => "${homedir}/server/stop.sh > /dev/null 2>&1",
		status     => "ps -fU ${name} | grep jetty > /dev/null 2>&1",
  }
}
