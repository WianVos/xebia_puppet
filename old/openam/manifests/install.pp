#todo dowload and install openam zip 
class openam::install{
	
	require openam::params

	#download and deploy
	common::source {
		"${openam::params::war_file_name}" :
			source_url => "${openam::params::download_war_url}",
			target => "${openam::params::tomcat_deploy_path}",
			notify => Service["tomcat-${openam::params::tomcat_instance_name}"]
	}	
	
}