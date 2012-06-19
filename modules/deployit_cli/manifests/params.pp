class deployit_cli::params{
	
	
	
	#prerequisite packages wich will be installed before the installation of deployit
	$packages = $::deployit_cli_packages ? {
		'' => ['unzip'], # Default value
		default => $::deployit_installed_packages,
	}
	
	#setting script_dir 
	$script_dir = $::deployit_script_dir ? {
		''	=>	'/etc/xebia_puppet/script',
		default	=> $::deployit_script_dir
	}
	#setting conf_dir 
	$conf_dir = $::deployit_conf_dir ? {
		''	=>	'/etc/xebia_puppet/config',
		default	=> $::deployit_conf_dir
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
		'' => '3.7.3',
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
	#INTEGRATION Section
	#setup integration dir, makes module play well with others
	$intergrate = $::deployit_cli_integrate ? {
		'' => true,
		default => $::deployit_cli_integrate
	}
	
	$intergration_classes = $::deployit_cli_intergration_classes ? {
		'' 			=> "",
		default		=> $::deployit_cli_intergration_classes
	}
	
	$xebia_universe	= $::deployit_xebia_universe ? {
		''			=> 'general',
		default		=> $::deployit_xebia_universe
	}
	
	$user_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA0g6DUrMHsEFYb58cam+WaUoqDi0qhHc6sVcVR/Rb9XGWo9faTCfWukS7iYqfNKhsm5+lLAmBIe7ycyfWHcxvWL3vOAZBNlceImPl96Ow2op2Kej9wMYD1jFcgGmekOzzW+ZyOWStXUyzXS48cijG1C/m7+zizezL8i10rPjIKpiQVOm8io8iPOXI69YKej1x9U8Lz/JKV353n7KoaAycu5q2YN2rGyCs7jnNZgoP7agrQZs2vsCHbHs5UZVQVYiKIKKo6TK7oZQHZom8dAi/01GZRBS/BKFr0VnyUA79xLrRwcJ2Wgtlc5K76ItKOxqpJ7Ji2HxSRyFkESkXnbXuTQ=="
	
}