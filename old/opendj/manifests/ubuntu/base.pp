class opendj::ubuntu::base {
	include opendj::params
	include opendj::packages	
	
	common::source {"opendj.zip":
                        source_url => 'http://download.forgerock.org/downloads/opendj/2.4.4/OpenDJ-2.4.4.zip',
                        target => $opendj::params::installpath
		}	
	common::ulimit{"opendj root nofiles ulimit":
			value => "65536"
			}
	class { 'install':
		require => Common::Source["opendj.zip"]
		}
	class { 'opendj::ubuntu::service':}	
	class { 'opendj::ubuntu::config':}
	
}
