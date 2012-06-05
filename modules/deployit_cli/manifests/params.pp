class deployit_cli::params{
	
	
	
	#prerequisite packages wich will be installed before the installation of deployit
	$packages = $::deployit_cli_packages ? {
		'' => ['openjdk-6-jdk','unzip'], # Default value
		default => $::deployit_installed_packages,
	}
	
	#install method . Possible options files or nexus 
	$install = $::deployit_cli_install ? {
		'' => "files", # Default value
		default => $::deployit_cli_install,
	}
	
	# install_filesource . only needed if install is files
	$install_filesource = $::deployit_cli_install_filesource ? {
		'' => "puppet:///modules/deployit",
		default => $::deployit_cli_install_filesource
	}
	
	
	#the deployit version which we will install
	$version = $::deployit_cli_version ? {
		'' => '3.7.0',
		default => $::deployit_cli_version
	}
	
	#the basedir where the perticular version of deployit will be installed
	$basedir = $::deployit_cli_basedir ? {
		'' => "/opt/deployit_base", # Default value
		default => $::deployit_cli_basedir,
	} 
	
	#the deployit homedir . this is a link to the perticular versioned basedir of deployit	
	$homedir = $::deployit_cli_homedir ? {
		'' => "/opt/deployit", # Default value
		default => $::deployit_cli_homedir,
	}
	
	#the deployit tmpdir. this is the directory that will be used for all kinds of temporary storage
	$tmpdir = $::deployit_cli_tmpdir ? {
		'' => '/var/tmp/deployit', # Default value
		default => $::deployit_cli_tmpdir,
	}
	#Module management peritcular variables
	#kudos to example 42 for the inspiration
	
	#setting $deployit_absent to true will result in deployit being removed
	$absent = $::deployit_cli_absent ? {
		'' => false,
		default => $::deployit_cli_absent
	}
	
	# setting deployit_disabled to true wil result in deployit being installed but no started
	$disabled = $::deployit_cli_disabled ? {
		'' => false,
		default => $::deployit_cli_disabled
	}
	
	# setting deployit_ensure to false wil result in the service not being started
	$ensure = $::deployit_cli_ensure ? {
		'' => running,
		default => $::deployit_cli_ensure
	}
	
	# setting the install owner
	$install_owner = $::deployit_cli_install_owner ? {
		'' => "deployit",
		default => $::deployit_cli_install_owner 
	}
	
	#setting the install group
	$install_group = $::deployit_cli_install_group ? {
		'' => "deployit",
		default => $::deployit_cli_install_group
	}	
	
}