class weblogic::install{ 

	#includes and requires
        require weblogic::params

        # get some variables to local
        $installpath = "${weblogic::params::installpath}"
		$jvmpath = "${weblogic::params::jvmpath}"	

        File { owner => root, group => root, mode => 700 }

        file {"${weblogic::params::installpath}":
                path => "${weblogic::params::installpath}",
                ensure => directory,
                }
        file {"${weblogic::params::tmpdir}":
                ensure => directory,
                }
        file {"weblogic binary":
                path   => "${weblogic::params::tmpdir}/${weblogic::params::jarfile}",
                source => "puppet:///modules/weblogic/${weblogic::params::jarfile}"
                }
        file {"weblogic silent installfile":
                path    => "${weblogic::params::tmpdir}/weblogic-silent.xml",
                content => template('weblogic/weblogic-silent.xml.erb'),
                }
	exec {"weblogic install":
		command	=> "${weblogic::params::jvmpath}/bin/java -jar ${weblogic::params::tmpdir}/${weblogic::params::jarfile} -mode=silent -silent_xml=${weblogic::params::tmpdir}/weblogic-silent.xml && touch ${weblogic::params::installpath}/weblogicinstalled",
		creates => "${weblogic::params::installpath}/weblogicinstalled",
		require => File["weblogic silent installfile","weblogic binary", "${weblogic::params::installpath}"],
		timeout => 0
		}




}
