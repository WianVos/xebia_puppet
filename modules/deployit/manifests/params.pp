class deployit::params{
	
	$nexus_url = "http://dexter.xebialabs.com/nexus"
	$nexus_user = "deployment"
	$nexus_password = "_#$(%RJf-W}"
	$nexus_tmpDir = "/var/tmp"
	
	#prerequisite packages wich will be installed before the installation of deployit
	$packages = $::deployit_packages ? {
		'' => ['openjdk-6-jdk'], # Default value
		default => $::deployit_installed_packages,
	}
	
	#install type . Possible options server of cli 
	$install = $::deployit_install ? {
		'' => "server", # Default value
		default => $::deployit_install,
	}
	
	#the deployit version which we will install
	$version = $::deployit_version ? {
		'' => '3.7',
		default => $::deployit_version
	}
	
	#the basedir where the perticular version of deployit will be installed
	$basedir = $::deployit_basedir ? {
		'' => "/opt/deployit/${version}", # Default value
		default => $::deployit_basedir,
	} 
	
	#the deployit homedir . this is a link to the perticular versioned basedir of deployit	
	$homedir = $::deployit_homedir ? {
		'' => '/opt/deployit', # Default value
		default => $::deployit_homedir,
	}
	
	#the deployit tmpdir. this is the directory that will be used for all kinds of temporary storage
	$tmpdir = $::deployit_tmpdir ? {
		'' => '/opt/deployit', # Default value
		default => $::deployit_tmpdir,
	}
	#Module management peritcular variables
	#kudos to example 42 for the inspiration
	
	#setting $deployit_absent to true will result in deployit being removed
	$absent = $::deployit_absent ? {
		'' => false,
		default => $::deployit_absent
	}
	
	# setting deployit_disabled to true wil result in deployit being installed but no started
	$disabled = $::deployit_disabled ? {
		'' => false,
		default => $::deployit_disabled
	}
	
	# setting the install owner
	$install_owner = $::deployit_install_owner ? {
		'' => "root",
		default => $::deployit_install_owner 
	}
	
	#setting the install group
	$install_group = $::deployit_install_group ? {
		'' => "root",
		default => $::deployit_install_group
	}	
	
}