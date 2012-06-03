class jetty::params{
	
	$nexus_url = ""
	$nexus_user = ""
	$nexus_password = ""
	$nexus_tmpDir = "/var/tmp"
	
	#prerequisite packages wich will be installed before the installation of jetty
	$packages = $::jetty_packages ? {
		'' => ['openjdk-6-jdk','unzip'], # Default value
		default => $::jetty_installed_packages,
	}
	
	#install method . Possible options files or nexus 
	$install = $::jetty_install ? {
		'' => "files", # Default value
		default => $::jetty_install,
	}
	
	# install_filesource . only needed if install is files
	$install_filesource = $::jetty_install_filesource ? {
		'' => "puppet:///modules/jetty",
		default => $::jetty_install_filesource
	}
	
	
	#the jetty version which we will install
	$version = $::jetty_version ? {
		'' => '3.7.0',
		default => $::jetty_version
	}
	
	#the basedir where the perticular version of jetty will be installed
	$basedir = $::jetty_basedir ? {
		'' => "/opt/jetty_base", # Default value
		default => $::jetty_basedir,
	} 
	
	#the jetty homedir . this is a link to the perticular versioned basedir of jetty	
	$homedir = $::jetty_homedir ? {
		'' => "/opt/jetty", # Default value
		default => $::jetty_homedir,
	}
	
	#the jetty tmpdir. this is the directory that will be used for all kinds of temporary storage
	$tmpdir = $::jetty_tmpdir ? {
		'' => '/var/tmp/jetty', # Default value
		default => $::jetty_tmpdir,
	}
	#Module management peritcular variables
	#kudos to example 42 for the inspiration
	
	#setting $jetty_absent to true will result in jetty being removed
	$absent = $::jetty_absent ? {
		'' => false,
		default => $::jetty_absent
	}
	
	# setting jetty_disabled to true wil result in jetty being installed but no started
	$disabled = $::jetty_disabled ? {
		'' => false,
		default => $::jetty_disabled
	}
	
	# setting jetty_ensure to false wil result in the service not being started
	$ensure = $::jetty_ensure ? {
		'' => running,
		default => $::jetty_ensure
	}
	
	# setting the install owner
	$install_owner = $::jetty_install_owner ? {
		'' => "jetty",
		default => $::jetty_install_owner 
	}
	
	#setting the install group
	$install_group = $::jetty_install_group ? {
		'' => "jetty",
		default => $::jetty_install_group
	}	
	
}