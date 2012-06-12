define jetty::clean ( $homedir ) {
  
  exec { "$homedir/stop-jetty":
    cwd       => "${homedir}",
    path      => [ "/bin/", "/usr/bin" ],
    command   => "${homedir}/server/stop.sh",
    onlyif    => "ps -fU ${name} | grep jetty",
    logoutput => on_failure,
  } ->
  exec { "$homedir/remove-jetty-folders":
    cwd       => "${homedir}",
    path      => [ "/bin/", "/usr/bin" ],
    command   => "rm -rf ${homedir}/server",
    onlyif    => "ls ${homedir}/server",
    logoutput => on_failure,
  }
  
}
