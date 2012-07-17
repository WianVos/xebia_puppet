class skeleton(
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
	$install_owner				= params_lookup('install_owner'),
	$install_group				= params_lookup('install_group'),
	$admin_password				= params_lookup('admin_password'),
	$jcr_repository_path		= params_lookup('jcr_repository_path'),
	$threads_min				= params_lookup('threads_min'),
	$threads_max				= params_lookup('threads_max'),
	$ssl						= params_lookup('ssl'),
	$http_bind_address			= params_lookup('http_bind_address'),
	$http_context_root			= params_lookup('http_context_root'),
	$http_port					= params_lookup('http_port'),
	$importable_packages_path	= params_lookup('importable_packages_path'),
	$universe				= params_lookup('universe'),
	$plugin_install				= params_lookup('plugin_install'),
	$key_install				= params_lookup('key_install'),
	$export_facts				= params_lookup('export_facts'),
	$export_config				= params_lookup('export_config'),
	$baseconfdir					= params_lookup('confdir'),
	$confdir					= params_lookup('confdir'),
	$scriptdir					= params_lookup('scriptdir'),
	$markerdir					= params_lookup('markerdir'),
	
		
) inherits skeleton::params{
	
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
	
	# create puppet module config dirs
	# these can be shared between modules so do a check for existance first
	if ! defined(File["${baseconfdir}"]) {
 		file { "${baseconfdir}" :
			ensure  => $manage_directory,
			owner	=> root,
			group   => root,
			mode    => 770,
		}		
	}

	if ! defined(File["${confdir}"]) {
                file { "${confdir}" :
                        ensure  => $manage_directory,
                        owner   => root,
                        group   => root,
                        mode    => 770,
                }
        }	

	if ! defined(File["${markerdir}"]) {
                file { "${markerdir}" :
                        ensure  => $manage_directory,
                        owner   => root,
                        group   => root,
                        mode    => 770,
                }
        }

	if ! defined(File["${scriptdir}"]) {
                file { "${scriptdir}" :
                        ensure  => $manage_directory,
                        owner   => root,
                        group   => root,
                        mode    => 770,
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
	
	
#download and unpack the needed files into the temporary directory in accordance with the installation type
# cli is downloaded always 
	
if $install == "files" {
	  
    	file {"skeleton-${version}-server.zip":
   		   ensure => $manage_files,
   	   	   path => "${tmpdir}/skeleton-${version}-server.zip",
      	   require => File["${tmpdir}"],
      	   source => "$install_filesource/skeleton-${version}-server.zip",
      	   before => Exec["unpack skeleton-server"]
        }
}

exec{
	"unpack skeleton-server":
		command 	=> "/usr/bin/unzip ${tmpdir}/skeleton-${version}-server.zip",
		cwd 		=> "${basedir}",
		creates 	=> "${basedir}/skeleton-${version}-server",
		require 	=> $install ? {
				default => File["${basedir}","skeleton-${version}-server.zip"],
				},
		user		=> "${install_owner}",
		}

file{
	"${homedir}/server":
		ensure 		=> $manage_link,
		target 		=> "${basedir}/skeleton-${version}-server",
		require 	=> Exec["unpack skeleton-server"],
		owner		=> "${install_owner}",
		group		=> "${install_group}"
	}	

file{
	"init functions":
		ensure 		=> $manage_files,
		source 		=> "$install_filesource/functions.sh",
		path		=> "/etc/init.d/functions",
		owner		=> root,
		group		=> root,
		mode		=> 700,
}

file{
	"init script":
		ensure 		=> $manage_files,
		source 		=> "$install_filesource/skeleton-initd.sh",
		path		=> "/etc/init.d/skeleton",
		owner		=> root,
		group		=> root,
		mode		=> 700,
}

file{
	"skeleton config file":
		ensure 		=> $manage_files,
		content 	=> template("skeleton/skeleton.conf.erb"),
		path		=> "${basedir}/skeleton-${version}-server/conf/skeleton.conf",
		owner		=> "${install_owner}",
		group		=> "${install_group}",
		require 	=> [Exec["unpack skeleton-server"],File["${homedir}/server"]],
		mode		=> 700,
		notify		=> Service["skeleton"],
		replace		=> false
}
if $plugin_install == true {

	file{ "plugin install":
		require 	=> Exec["unpack skeleton-server"],
	        source 		=> "puppet:///modules/skeleton/plugins/",
		sourceselect	=> all,
		recurse 	=> remote,
		owner		=> "${install_owner}",
		group		=> "${install_group}",
		ensure		=> "${manage_files}",
		path		=> "${homedir}/server/plugins",
		notify		=> Service["skeleton"]
		}							
}

if $key_install == true {
	file{ "key install":
		require 	=> [Exec["unpack skeleton-server"]],
	        source 		=> "puppet:///modules/skeleton/keys/",
		sourceselect	=> all,
		recurse 	=> remote,
		owner		=> "${install_owner}",
		group		=> "${install_group}",
		ensure		=> "${manage_files}",
		path		=> "${homedir}/keys/",
		mode		=> "700"
		}							
}



exec{
	"init skeleton":
		creates		=> "${homedir}/server/repository",
		command		=> "${homedir}/server/bin/server.sh -setup -reinitialize -force",
		user		=> "${install_owner}",
		require		=> [Exec["unpack skeleton-server"],File["${homedir}/server","skeleton config file"]],
		logoutput	=> true,
		 
}


service{
	'skeleton':
		require 	=> [File["${homedir}/server","skeleton config file"],Exec["init skeleton"]],
		ensure		=> "${ensure_service}",
		hasrestart	=> true,
	}
	
	
}
	
	
	
	
	
	
	


