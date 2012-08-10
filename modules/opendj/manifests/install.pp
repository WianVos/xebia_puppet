class opendj::install (
	$ensure = "present",
	$basedn = "dc=${opendj::universe},${opendj::basednsuffix}"
	
) {
	
	
	if "${ensure}" == "present" {
		case $opendj::install {
			source : {
				xebia_common::source {
					"${opendj::install_file}" :
						source_url => "${opendj::install_source_url}",
						target => "/opt",
						regdir => "${opendj::markerdir}"
				}
				exec {
					"opendj install" :
						command =>
						"${opendj::homedir}/setup --cli --baseDN ${basedn} --ldapPort ${opendj::ldapport} --adminConnectorPort ${opendj::mgtport} --rootUserDN cn=\'${opendj::rootuser}\' --rootUserPassword ${opendj::rootpassword} --no-prompt --noPropertiesFile && touch ${opendj::homedir}/puppetinstalledopendj.txt ",
						creates => "${opendj::homedir}/puppetinstalledopendj.txt",
						require => Xebia_common::Source["${opendj::install_file}"],
						logoutput => true
				}
			}
			default : {
				notify {
					"no default installation method for available for jenkins" :
				}
			}
		}
	}
}