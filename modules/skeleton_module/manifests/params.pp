class skeleton::params{
	
	$nexus_url = ""
	$nexus_user = ""
	$nexus_password = ""
	$nexus_tmpDir = "/var/tmp"
	
	#prerequisite packages wich will be installed before the installation of skeleton
	$packages = $::skeleton_packages ? {
		'' => ['openjdk-6-jdk','unzip'], # Default value
		default => $::skeleton_installed_packages,
	}
	
	#install method . Possible options files or nexus 
	$install = $::skeleton_install ? {
		'' => "files", # Default value
		default => $::skeleton_install,
	}
	
	# install_filesource . only needed if install is files
	$install_filesource = $::skeleton_install_filesource ? {
		'' => "puppet:///modules/skeleton",
		default => $::skeleton_install_filesource
	}
	
	
	#the skeleton version which we will install
	$version = $::skeleton_version ? {
		'' => '3.7.0',
		default => $::skeleton_version
	}
	
	#the basedir where the perticular version of skeleton will be installed
	$basedir = $::skeleton_basedir ? {
		'' => "/opt/skeleton_base", # Default value
		default => $::skeleton_basedir,
	} 
	
	#the skeleton homedir . this is a link to the perticular versioned basedir of skeleton	
	$homedir = $::skeleton_homedir ? {
		'' => "/opt/skeleton", # Default value
		default => $::skeleton_homedir,
	}
	
	#the skeleton tmpdir. this is the directory that will be used for all kinds of temporary storage
	$tmpdir = $::skeleton_tmpdir ? {
		'' => '/var/tmp/skeleton', # Default value
		default => $::skeleton_tmpdir,
	}
	#Module management peritcular variables
	#kudos to example 42 for the inspiration
	
	#setting $skeleton_absent to true will result in skeleton being removed
	$absent = $::skeleton_absent ? {
		'' => false,
		default => $::skeleton_absent
	}
	
	# setting skeleton_disabled to true wil result in skeleton being installed but no started
	$disabled = $::skeleton_disabled ? {
		'' => false,
		default => $::skeleton_disabled
	}
	
	# setting skeleton_ensure to false wil result in the service not being started
	$ensure = $::skeleton_ensure ? {
		'' => running,
		default => $::skeleton_ensure
	}
	
	# setting the install owner
	$install_owner = $::skeleton_install_owner ? {
		'' => "skeleton",
		default => $::skeleton_install_owner 
	}
	
	#setting the install group
	$install_group = $::skeleton_install_group ? {
		'' => "skeleton",
		default => $::skeleton_install_group
	}	
	
}