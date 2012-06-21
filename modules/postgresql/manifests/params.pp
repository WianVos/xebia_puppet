class postgresql::params{
	
	$nexus_url = ""
	$nexus_user = ""
	$nexus_password = ""
	$nexus_tmpDir = "/var/tmp"
	
	#prerequisite packages wich will be installed before the installation of postgresql
	$packages = $::postgresql_packages ? {
		'' => ['openjdk-6-jdk','unzip'], # Default value
		default => $::postgresql_installed_packages,
	}
	
	#install method . Possible options files or nexus 
	$install = $::postgresql_install ? {
		'' => "files", # Default value
		default => $::postgresql_install,
	}
	
	# install_filesource . only needed if install is files
	$install_filesource = $::postgresql_install_filesource ? {
		'' => "puppet:///modules/postgresql",
		default => $::postgresql_install_filesource
	}
	
	# install_source_url . only needed if install is source
	$install_source_url = $::postgresql_install_source_url ? {
		'' => "http://",
		default => $::postgresql_install_source_url
	}
	
	#the postgresql version which we will install
	$version = $::postgresql_version ? {
		'' => '3.7.0',
		default => $::postgresql_version
	}
	
	#the basedir where the perticular version of postgresql will be installed
	$basedir = $::postgresql_basedir ? {
		'' => "/opt/postgresql_base", # Default value
		default => $::postgresql_basedir,
	} 
	
	#the postgresql homedir . this is a link to the perticular versioned basedir of postgresql	
	$homedir = $::postgresql_homedir ? {
		'' => "/opt/postgresql", # Default value
		default => $::postgresql_homedir,
	}
	
	#the postgresql tmpdir. this is the directory that will be used for all kinds of temporary storage
	$tmpdir = $::postgresql_tmpdir ? {
		'' => '/var/tmp/postgresql', # Default value
		default => $::postgresql_tmpdir,
	}
	#Module management peritcular variables
	#kudos to example 42 for the inspiration
	
	#setting $postgresql_absent to true will result in postgresql being removed
	$absent = $::postgresql_absent ? {
		'' => false,
		default => $::postgresql_absent
	}
	
	# setting postgresql_disabled to true wil result in postgresql being installed but no started
	$disabled = $::postgresql_disabled ? {
		'' => false,
		default => $::postgresql_disabled
	}
	
	# setting postgresql_ensure to false wil result in the service not being started
	$ensure = $::postgresql_ensure ? {
		'' => running,
		default => $::postgresql_ensure
	}
	
	# setting the install owner
	$install_owner = $::postgresql_install_owner ? {
		'' => "postgresql",
		default => $::postgresql_install_owner 
	}
	
	#setting the install group
	$install_group = $::postgresql_install_group ? {
		'' => "postgresql",
		default => $::postgresql_install_group
	}	
	
	$intergrate = $::postgresql_intergrate ? {
		''	=> false,
		default	=> $::postgresql_intergrate 
	}
	
	$facts_import_tags = $::postgresql_facts_import_tags ? {
		''	=> 'none',
		default => $::postgresql_facts_import_tags
	}
	
	$infra_dir				= "/etc/xebia_puppet"
	$marker_dir 			= "${infra_dir}/marker"
	$script_dir 			= "${infra_dir}/script"
	$config_dir 			= "${infra_dir}/config"
	$tmpdir						= 	'/var/tmp/deployit'
	$absent 					=	false
	$disabled 					= 	false
	$ensure						= 	'running'
	$import_facts				= 	true
	$import_config				= 	true
	$export_facts				= 	true
	$export_config				= 	true
	$install					= 	'files'
	$universe					=   'default'
	$customer					=	'default'
	$application				=	'defautl'
}