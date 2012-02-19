class openam::params {

#default version is 9.5.4
	$version = "9.5.4"

	
#todo make the download link more dynamic
	case $version {
		"9.5.4" : {
			$download_war_url =	"http://download.forgerock.org/downloads/openam/snapshot9.5/openam_954.war"
			$download_tools_url = "http://download.forgerock.org/downloads/openam/snapshot9.5/ssoAdminTools_954.zip"
			$tomcat_instance_name = "openam-954"
			$tomcat_deploy_path	= "/srv/tomcat/${tomcat_instance_name}/webapps"
			$war_file_name = "openam_954.war"
		}
		default : {
			$download_war_url =	"http://download.forgerock.org/downloads/openam/snapshot9.5/openam_954.war"
			$download_tools_url = "http://download.forgerock.org/downloads/openam/snapshot9.5/ssoAdminTools_954.zip"
			$tomcat_instance_name = "openam-954"
			$tomcat_deploy_path	= "/srv/tomcat/${tomcat_instance_name}/webapps"
			$war_file_name = "openam_954.war"
		}
	}
}

