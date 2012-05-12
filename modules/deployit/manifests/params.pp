class deployit::params {

	$completeVersion = $deployit::completeVersion ? {
										"" => "3.7",
										default => "${deployit::completeVersion}"
										}
	$deployit_tmpdir = "/var/tmp/deployit"
	$deployit_home_dir = "/opt/deployit"
	$deployit_install_dir = "/opt/deployit_${completeVersion}/"
	
	# nexus settings
	$nexus_url = "http://dexter.xebialabs.com/nexus"
    $nexus_username = "deployment"
    $nexus_password = "_#$(%RJf-W}"
    
    
    
   
}
