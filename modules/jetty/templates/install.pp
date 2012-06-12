define jetty::install (
  $ensure,
  $installdir,
  $download_url,
  $runtime_user
) {

  $ensure_user = $ensure ? {
    absent  => absent,
    default => present,
  }

  $ensure_group = $ensure ? {
    absent  => absent,
    default => present,
  }

  user { $runtime_user:
    ensure => $ensure_user,
    gid    => $runtime_user,
  }

  group { $runtime_user:
    ensure => $ensure_group,
  }

  if $ensure != 'absent' {

    Group[ $runtime_user ] ->
    User[ $runtime_user ] ->
    Exec[ "${installdir}/download-and-install-jetty" ]

    exec { "${installdir}/download-and-install-jetty":
      cwd       => '/tmp',
      command   => "curl ${download_url} -o jetty.tar.gz &&
                    mkdir -p ${installdir} &&
                    tar -xzf jetty.tar.gz -C ${installdir} --strip-components 1 &&
                    rm jetty.tar.gz &&
                    chown -R ${runtime_user}:${runtime_user} ${installdir}",
      path      => [ '/bin/', '/usr/bin' ],
      creates   => "${installdir}/start.jar",
      logoutput => on_failure,
    }

  } else {

    User[ $runtime_user ] ->
    Group[ $runtime_user ] ->
    Exec [ "${installdir}/remove-jetty" ]

    exec { "${installdir}/remove-jetty":
      cwd       => '/tmp',
      command   => "rm -rf ${installdir}",
      path      => [ '/bin/', '/usr/bin' ],
      onlyif    => "ls ${installdir}",
      logoutput => on_failure,
    }

  }

}
