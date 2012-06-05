class jrockit::install {

	#includes and requires
	require jrockit::params
	
	# get some variables to local
	$installpath = "${jrockit::params::installpath}"

	File { owner => root, group => root, mode => 700 }
	
	file {"${jrockit::params::installpath}":
		path => "${jrockit::params::installpath}",
		ensure => directory,
		}
	file {"${jrockit::params::tmpdir}":
		ensure => directory,
		}

	file {"jrockit binary":
		path   => "${jrockit::params::tmpdir}/${jrockit::params::binfile}",
		source => "puppet:///modules/jrockit/${jrockit::params::binfile}"
		} 	
	file {"jrockit silent installfile":
		path 	=> "${jrockit::params::tmpdir}/jrockit-silent.xml",
		content => template('jrockit/jrockit-silent.xml.erb'),
		}	
	
	# the almighty exec
	# the touch is there because i wasn't in the mood for typing in the actual jrockit install path
	exec {"install jrockit":
		command => "${jrockit::params::tmpdir}/${jrockit::params::binfile} -silent_xml=${jrockit::params::tmpdir}/jrockit-silent.xml -mode=silent && touch ${jrockit::params::installpath}/jrockitinstalled",
		creates => "${jrockit::params::installpath}/jrockitinstalled",
		require => File["jrockit binary", "jrockit silent installfile", "${jrockit::params::installpath}"],
		}
}
