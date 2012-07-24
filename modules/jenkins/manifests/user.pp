define jenkins::user (
	$ensure = "present",
	$template = "default",
	$api_token = 'none',
	$password = '#jbcrypt:$2a$10$WZ6rks8d8flJcp8m7aDiRuIsu6ZaJo.T2Jt69YQ0BXmltyZb9Kihe',
	$mail = "${name}@xebia_puppet.com"
	) {
	if !defined(Concat::Fragment["user_config_start"]) {
		concat::fragment {
			"user_config_start" :
				target => "${jenkins::jenkins_config}",
				order => "20",
				content => template("jenkins/config_user_start.xml.erb"),
				require => Class["jenkins::config"]
		}
	}
	concat::fragment {
		"${name}_${template}_user" :
			target => "${jenkins::jenkins_config}",
			order => "21",
			content => template("jenkins/config_user${template}.xml.erb"),
	}
	if !defined(Concat::Fragment["user_config_end"]) {
		concat::fragment {
			"user_config_start" :
				target => "${jenkins::jenkins_config}",
				order => "29",
				content => template("jenkins/config_user_end.xml.erb"),
				require => Class["jenkins::config"]
		}
	}
	if !defined(File["${jenkins::jenkins_userdb}"]) {
		file {
			"${jenkins::jenkins_userdb}" :
				owner => "${jenkins::install_owner}",
				group => "${jenkins::install_group}",
				require => Class["jenkins::install"],
				mode => "0770",
				ensure => "${jenkins::manage_directory}"
		}
	}
	file {
		"${jenkins::jenkins_userdb}/${name}" :
			owner => "${jenkins::install_owner}",
			group => "${jenkins::install_group}",
			require => File["${jenkins::jenkins_userdb}"],
			mode => "0770",
			ensure => "${jenkins::manage_directory}"
	}
	file {
		"${jenkins::jenkins_userdb}/${name}/config.xml":
			owner => "${jenkins::install_owner}",
			group => "${jenkins::install_group}",
			require => File["${jenkins::jenkins_userdb}/${name}"],
			content => template("jenkins/user_config.xml.erb"),
			mode => "0770",
			ensure => "${jenkins::manage_files}"
	}
}