class jenkins::repository inherits jenkins {

  case $::operatingsystem {

    ubuntu , debian: {
      file { 'jenkins.list':
        ensure => present,
        path => '/etc/apt/sources.list.d/jenkins.list',
        mode => '0644',
        owner => 'root',
        group => 'root',
        content => 'deb http://pkg.jenkins-ci.org/debian binary/',
        before => Exec['aptkey_add_jenkins'],
      }
      exec { 'aptkey_add_jenkins':
        command => 'wget -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add -',
        unless => 'apt-key list | grep -q D50582E6',
        path => '/bin:/usr/bin',
      }
      exec { 'aptget_update_jenkins':
        command => 'apt-get update',
        subscribe => File['jenkins.list'],
        path => '/bin:/usr/bin',
      }

    }

    default: {
    }

  }

}