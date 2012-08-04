class opendj::configure (
	$ensure = "present"
) {
	if $ensure == "present" {
		xebia_common::ulimit {
			"opendj root nofiles ulimit" :
				value => "65536"
		}
		file {
			"opendj java params" :
				path => "${opendj::homedir}/config/java.properties",
				content => template("opendj/java_params.erb"),
				notify => Exec["opendj commit java_params"],
				require => Exec["opendj install"],
				ensure => "${ensure}"
		}
		exec {
			"opendj commit java_params" :
				command => "${opendj::homedir}/bin/dsjavaproperties",
				require => Class["opendj::install"],
		}
		exec {
			"opendj service setup" :
				command =>
				"${opendj::homedir}/bin/create-rc-script -f /etc/init.d/opendj -u root",
				creates => "/etc/init.d/opendj",
				require => Class["opendj::install"],
		}
	}
	else {
		file {
			"opendj java params" :
				path => "${opendj::homedir}/config/java.properties",
				content => template("opendj/java_params.erb"),
				notify => Exec["opendj commit java_params"],
				require => Exec["opendj install"],
				ensure => "${ensure}"
		}
	}
}