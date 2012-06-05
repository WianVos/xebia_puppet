class opendj::ubuntu::service(
	$running_user="root"
	)
{
	include opendj::params

        exec {"opendj service setup":
                command => "${opendj::params::installpath}/OpenDJ-2.4.4/bin/create-rc-script -f /etc/init.d/opendj -u root",
                creates => "/etc/init.d/opendj",
		require => Exec['opendj install'],
                }

	service {"opendj":
		ensure => running,
		require => Exec['opendj service setup'],
		hasstatus => false,
		pattern => 'OpenDJ-2.4.4'
		}






}
