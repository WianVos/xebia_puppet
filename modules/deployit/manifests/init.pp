class deployit(
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
	$universe				= params_lookup('universe', 'global'),
	$plugin_install				= params_lookup('plugin_install'),
	$key_install				= params_lookup('key_install'),
	$export_config				= params_lookup('export_config'),
	$infradir					= params_lookup('infradir'),
	$confdir					= params_lookup('confdir'),
	$scriptdir					= params_lookup('scriptdir'),
	$markerdir					= params_lookup('markerdir'),
	$import_facts				= params_lookup('import_facts'),
	$import_config				= params_lookup('import_config'),
	$cli_conf_options				= params_lookup('cli_conf_options')
		
		
) inherits deployit::params{
	
	#set various manage parameters in accordance to the $absent directive
	$manage_package = $absent ? {
		true 	=> "absent",
		false 	=> "installed",
		default => "installed"
	}	
	
	$manage_directory = $absent ? {
		true 	=> "absent",
		default => "directory",
	}
	
	$manage_link = $absent ? {
		true 	=> "absent",
		default => "link",
	}
	
	$manage_files = $absent ? {
		true 	=> "absent",
		false 	=> "present",
		default => "present"
	}
	
	$manage_user = $absent ? {
		true 	=> "absent",
		false 	=> "present",
		default => "present"
	}
	

	$ensure_service = $ensure ? {
		true	=> "running",
		false 	=> "stoppped",
		default	=> "running"
	}
	
	
	 
	file {
		["${infradir}", "${markerdir}", "${scriptdir}", "${confdir}"] :
			ensure => "${manage_directory}",
			owner => root,
			group => root,
			mode => 770,
	}
	
	
	#xebia_puppet intergration stuff
	
	#export deployit user
	if $export_config {
		@@deployit::exports::create_deployit_user{"deployit_user":
			key => params_lookup('install_owner_key', global),
			user_name => "${install_owner}",
			group	=> "${install_owner}",
			universe => "${universe}"
		
		}	
	}
	if $import_config {
		Deployit::Imports::Export_jetty <<| |>>
		Deployit::Imports::Export_postgresql <<| |>>
	}
	
#
	 file {
		"${confdir}/deployit.conf" :
			require => File["${confdir}"],
			content =>
			inline_template("<% cli_conf_options.sort_by {|key, value| key}.each do |key, value| %><%= key %>='<%= value %>' \n<% end %>")
	}	
	
	#install packages as needed by deployit	
	package{$packages:
		ensure => $manage_package,
		before => File["$tmpdir","$basedir"]
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
# server in downloaded only if installation type is set to server
	
if $install == "files" {
	  
 	file {"deployit-${version}-cli.zip":
   		   ensure => $manage_files,
   	   	   path => "${tmpdir}/deployit-${version}-cli.zip",
      	   require => File["${tmpdir}"],
      	   source => "$install_filesource/deployit-${version}-cli.zip",
      	   before => Exec["unpack deployit-cli"]
      	   	}	  
    
    
    file {"deployit-${version}-server.zip":
   		   ensure => $manage_files,
   	   	   path => "${tmpdir}/deployit-${version}-server.zip",
      	   require => File["${tmpdir}"],
      	   source => "$install_filesource/deployit-${version}-server.zip",
      	   before => Exec["unpack deployit-server"]
        }
}

	
	
	
exec{
	 "unpack deployit-cli":
		command 	=> "/usr/bin/unzip ${tmpdir}/deployit-${version}-cli.zip",
		cwd 		=> "${basedir}",
		creates 	=> "${basedir}/deployit-${version}-cli",
		require 	=> $install ?{
				default => File["${basedir}","deployit-${version}-cli.zip"],
				},
		user		=>	"${install_owner}",
		}
	

exec{
	"unpack deployit-server":
		command 	=> "/usr/bin/unzip ${tmpdir}/deployit-${version}-server.zip",
		cwd 		=> "${basedir}",
		creates 	=> "${basedir}/deployit-${version}-server",
		require 	=> $install ? {
				default => File["${basedir}","deployit-${version}-server.zip"],
				},
		user		=> "${install_owner}",
		}

file{
	"${homedir}/cli":
		ensure 		=> $manage_link,
		target 		=> "${basedir}/deployit-${version}-cli",
		require 	=> Exec["unpack deployit-cli"],
		owner		=> "${install_owner}",
		group		=> "${install_group}"
	}				

file{
	"${homedir}/server":
		ensure 		=> $manage_link,
		target 		=> "${basedir}/deployit-${version}-server",
		require 	=> Exec["unpack deployit-server"],
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
		source 		=> "$install_filesource/deployit-initd.sh",
		path		=> "/etc/init.d/deployit",
		owner		=> root,
		group		=> root,
		mode		=> 700,
}

file{
	"deployit config file":
		ensure 		=> $manage_files,
		content 	=> template("deployit/deployit.conf.erb"),
		path		=> "${basedir}/deployit-${version}-server/conf/deployit.conf",
		owner		=> "${install_owner}",
		group		=> "${install_group}",
		require 	=> [Exec["unpack deployit-server"],File["${homedir}/server"]],
		mode		=> 700,
		notify		=> Service["deployit"],
		replace		=> false
}
if $plugin_install == true {

	file{ "plugin install":
		require 	=> Exec["unpack deployit-server"],
	        source 		=> "puppet:///modules/deployit/plugins/",
		sourceselect	=> all,
		recurse 	=> remote,
		owner		=> "${install_owner}",
		group		=> "${install_group}",
		ensure		=> "${manage_files}",
		path		=> "${homedir}/server/plugins",
		notify		=> Service["deployit"]
		}							
}

if $key_install == true {
#	file{ "key dir":
#		owner		=> "${install_owner}",
#		group		=> "${install_group}",
#		ensure		=> "${manage_directory}",
#		path		=> "${homedir}/keys",
#		
#	}
	file{ "key install":
		require 	=> [Exec["unpack deployit-server"]],
	        source 		=> "puppet:///modules/deployit/keys/",
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
	"init deployit":
		creates		=> "${homedir}/server/repository",
		command		=> "${homedir}/server/bin/server.sh -setup -reinitialize -force",
		user		=> "${install_owner}",
		require		=> [Exec["unpack deployit-server"],File["${homedir}/server","deployit config file"]],
		logoutput	=> true,
		 
}

file {"${scriptdir}/$name":
                        require                 => File["${scriptdir}"],
                        source                  => "puppet:///modules/deployit/features/cli_python/",
                        sourceselect    	=> all,
                        recurse                 => remote,
                        owner                   => "${install_owner}",
                        group                   => "${install_group}",
                        ensure                  => "${manage_files}"

                }
service{
	'deployit':
		require 	=> [File["${homedir}/server","deployit config file"],Exec["init deployit"]],
		ensure		=> "${ensure_service}",
		hasrestart	=> true,
	}
	
	
}
	
	
	
	
	
	
	


