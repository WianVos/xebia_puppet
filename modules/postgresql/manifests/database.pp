define postgresql::database(
  $ensure=present,
  $owner="postgresql",
  $encoding=false,
  $template="template1",
  $homedir = params_lookup('homedir'),
  $install_owner = "postgresql"
  ) {
  # credits to camp to camp 
  $ownerstring = $owner ? {
    false => "",
    default => "-O $owner"
  }

  $encodingstring = $encoding ? {
    false => "",
    default => "-E $encoding",
  }

  case $ensure {
    present: {
      exec { "Create $name postgresql db":
        command => "/usr/bin/sudo /bin/su - ${install_owner} -c \"${homedir}/bin/createdb ${ownerstring} ${encodingstring} ${name} -T ${template}\"",
		unless => "/bin/su - postgresql -c \"${homedir}/bin/psql -l |/bin/grep ${name} \"",
        require => Service['postgresql']
      }
    }
    absent: {
      exec { "Remove $name postgresql db":
        command => "${homedir}/bin/dropdb $name",
        user => "${install_owner}",
        onlyif => "/usr/bin/test \$(${homedir}/bin/psql -tA -c \"SELECT count(*)=1 FROM pg_catalog.pg_database where datname='${name}';\") = t",
        require => Service['postgresql']
      }
    }
    default: {
      fail "Invalid 'ensure' value '$ensure' for postgresql::database"
    }
  }
}
