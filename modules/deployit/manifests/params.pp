class deployit::params{
	
	$nexus_url = ""
	$nexus_user = ""
	$nexus_password = ""
	$nexus_tmpDir = "/var/tmp"
	
	#prerequisite packages wich will be installed before the installation of deployit
	$packages = $::deployit_packages ? {
		'' => ['openjdk-6-jdk','unzip'], # Default value
		default => $::deployit_installed_packages,
	}
	
	#install method . Possible options files or nexus 
	$install = $::deployit_install ? {
		'' => "files", # Default value
		default => $::deployit_install,
	}
	
	# install_filesource . only needed if install is files
	$install_filesource = $::deployit_install_filesource ? {
		'' => "puppet:///modules/deployit",
		default => $::deployit_install_filesource
	}
	
	
	#the deployit version which we will install
	$version = $::deployit_version ? {
		'' => '3.7.0',
		default => $::deployit_version
	}
	
	#the basedir where the perticular version of deployit will be installed
	$basedir = $::deployit_basedir ? {
		'' => "/opt/deployit_base", # Default value
		default => $::deployit_basedir,
	} 
	
	#the deployit homedir . this is a link to the perticular versioned basedir of deployit	
	$homedir = $::deployit_homedir ? {
		'' => "/opt/deployit", # Default value
		default => $::deployit_homedir,
	}
	
	#the deployit tmpdir. this is the directory that will be used for all kinds of temporary storage
	$tmpdir = $::deployit_tmpdir ? {
		'' => '/var/tmp/deployit', # Default value
		default => $::deployit_tmpdir,
	}
	
	#INTEGRATION Section
	#setup integration dir, makes module play well with others
	$intergrate = $::deployit_integrate ? {
		'' => true,
		default => $::deployit_integrate
	}
	
	$intergration_classes = $::deployit_intergration_classes ? {
		'' 			=> [xebia_common::regdir,deployit::features::expconn],
		default		=> $::deployit_intergration_classes
	}
	
	$xebia_universe	= $::deployit_xebia_universe ? {
		''			=> 'general',
		default		=> $::deployit_xebia_universe
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
	
	# setting deployit_ensure to false wil result in the service not being started
	$ensure = $::deployit_ensure ? {
		'' => running,
		default => $::deployit_ensure
	}
	
	# setting the install owner
	$install_owner = $::deployit_install_owner ? {
		'' => "deployit",
		default => $::deployit_install_owner 
	}
	
	#setting the install group
	$install_group = $::deployit_install_group ? {
		'' => "deployit",
		default => $::deployit_install_group
	}
	
	#Deployit specific parameters
	
	$admin_password = $::deployit_admin_password ? {
		'' 		=> "admin",
		default => $::deployit_admin_password
	}
	
	$jcr_repository_path = $::deployit_jcr_repository_path ? {
		''		=> "repository",
		default => $::deployit_jcr_repository_path
	}
	
	$threads_min = $::deployit_threads_min ?{
		''		=> "3",
		default	=> $::deployit_threads_min
	}

	$ssl = $::deployit_ssl ?{
		''		=> 'false',
		default	=> $::deployit_ssl
	}
	
	$http_bind_address = $::deployit_http_bind_address ? {
		''		=>	"0.0.0.0",
		default	=>	$::deployit_http_bind_address
	}
	
	$http_context_root = $::deployit_http_context_root ? {
		''		=> "/deployit",
		default	=> $::deployit_http_context_root
	}
	
	$threads_max = $::deployit_threads_max ? {
		''		=> "24",
		default	=> $::deployit_threads_max
	}
	
	$http_port = $::deployit_http_port ?{
		''		=> "4516",
		default	=> $::deployit_http_port
	}
	
	$importable_packages_path = $::deployit_importable_packages_path ? {
		'' 		=> "importablePackages",
		default => $::deployit_importable_packages_path
	}	
}