class opendj::ubuntu::config(
	$java_parameters="-server -Xmx2046m -Xms1024m"
)
{
        include opendj::params

	file {"opendj java params":
		path => "${opendj::params::installpath}/OpenDJ-2.4.4/config/java.properties",
		content => template("opendj/java_params.erb"),
		notify => Exec["opendj commit java_params"],
		require => Exec["opendj install"],
		}
        
	exec {"opendj commit java_params":
                command => "${opendj::params::installpath}/OpenDJ-2.4.4/bin/dsjavaproperties",
                require => Exec['opendj install'],
		notify => Service['opendj'],
                }





}
