class jenkins (
	$packages 					= params_lookup('packages'), 
	$version 					= params_lookup('version'),
	$basedir 					= params_lookup('basedir'),
	$homedir 					= params_lookup('homedir'),
	$tmpdir						= params_lookup('tmpdir'),
	$absent 					= params_lookup('absent'),
	$disabled 					= params_lookup('disabled'),
	$ensure						= params_lookup('ensure'),
	$install					= params_lookup('install'),
	$install_filesource			= params_lookup('install_filesource'),
	$install_package			= params_lookup('install_package'),
	$install_owner				= params_lookup('install_owner'),
	$install_group				= params_lookup('install_group'),
	$universe					= params_lookup('universe'),
	$plugin_install				= params_lookup('plugin_install'),
	$key_install				= params_lookup('key_install'),
	$export_facts				= params_lookup('export_facts'),
	$export_config				= params_lookup('export_config'),
	$baseconfdir				= params_lookup('confdir'),
	$confdir					= params_lookup('confdir'),
	$scriptdir					= params_lookup('scriptdir'),
	$markerdir					= params_lookup('markerdir')
	) inherits jenkins::params {
		#set various manage parameters in accordance to the $absent directive
	$manage_package = absent ? {
		true 	=> "absent",
		false 	=> "installed",
		default => "installed"
	}	
	
	$manage_directory = absent ? {
		true 	=> "absent",
		default => "directory",
	}
	
	$manage_link = absent ? {
		true 	=> "absent",
		default => "link",
	}
	
	$manage_files = absent ? {
		true 	=> "absent",
		false 	=> "present",
		default => "present"
	}
	
	$manage_user = absent ? {
		true 	=> "absent",
		false 	=> "present",
		default => "present"
	}
	

	$ensure_service = ensure ? {
		true	=> "running",
		false 	=> "stoppped",
		default	=> "running"
	}
	
   file { "${baseconfdir}" :
                        ensure  => $manage_directory,
                        owner   => root,
                        group   => root,
                        mode    => 770,
                }
        	
	if ! defined(File["${confdir}"]) {
                file { "${confdir}" :
                        ensure  => $manage_directory,
                        owner   => root,
                        group   => root,
                        mode    => 770,
                        require => File["${baseconfdir}"]
                }
        }	

	if ! defined(File["${markerdir}"]) {
                file { "${markerdir}" :
                        ensure  => $manage_directory,
                        owner   => root,
                        group   => root,
                        mode    => 770,
                        require => File["${baseconfdir}"]
                }
        }

	if ! defined(File["${scriptdir}"]) {
                file { "${scriptdir}" :
                        ensure  => $manage_directory,
                        owner   => root,
                        group   => root,
                        mode    => 770,
                        require => File["${baseconfdir}"]
                }
        }
	
	
	
	#install packages as needed by skeleton
	xebia_common::features::extra_package{$packages:
		ensure	=> "${manage_package}",
		before  => File["${tmpdir}","${basedir}"]
	}	
	#create the needed users
	group {
		"$install_group":
			ensure => $manage_user,
	}
	
	user {
		"$install_owner":
			ensure 		=> $manage_user,
			gid 		=> "${install_group}",
			managehome 	=> false,
			home 		=> "${homedir}",
			system 		=> true,
			
	}
	#create the needed directory structures
	
	#tmpdir
	file {"${tmpdir}":
		ensure 	=> "${manage_directory}",
		owner 	=> "${install_owner}",
		group	=> "${install_group}"
	}
	#basedir
	file {"${basedir}":
		ensure 	=> "${manage_directory}",
		owner 	=> "${install_owner}",
		group	=> "${install_group}"
	}
	#homedir
	file {"${homedir}":
		ensure 	=> "${manage_directory}",
		owner 	=> "${install_owner}",
		group	=> "${install_group}"
	}
	
	#install 
	include jenkins::install
	#configure
	# We'll put the install in a separate class so we can extend the isntallation methods in the future
	
	#intergrate
	
	
	}
