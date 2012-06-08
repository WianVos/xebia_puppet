#
#
class deployit_cli(
	$packages 					= $deployit_cli::params::packages, 
	$version 					= $deployit_cli::params::version,
	$basedir 					= $deployit_cli::params::basedir,
	$homedir 					= $deployit_cli::params::homedir,
	$tmpdir						= $deployit_cli::params::tmpdir,
	$absent 					= $deployit_cli::params::absent,
	$disabled 					= $deployit_cli::params::disabled,
	$ensure						= $deployit_cli::params::ensure,
	$install					= $deployit_cli::params::install,
	$install_filesource			= $deployit_cli::params::install_filesource,
	$install_owner				= $deployit_cli::params::install_owner,
	$install_group				= $deployit_cli::params::install_group,
	$intergrate					= $deployit_cli::params::intergrate,
	$intergration_classes		= $deployit_cli::params::intergration_classes
	
		
) inherits deployit_cli::params{
	
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
	
	#xebia_puppet intergration stuff
	if $intergrate == true {
		class{$intergration_classes:}
		
		file {"deployit cli scripts":
			require => File["/etc/xebia_puppet/scripts"],
			source 	=> "puppet:///modules/deployit_cli/features/cli_python/",
			recurse => true,
			path 	=> "/etc/xebia_puppet/scripts"	
		}
		
		#import deployit settings 
		
			
	}
	
	#install packages as needed by deployit_cli	
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
if $install == "nexus" {	
    class {
		'nexus' :
			url => "${deployit_cli::params::nexus_url}",
			username => "${deployit_cli::params::nexus_user}",
			password => "${deployit_cli::params::nexus_password}"
	}
	
	nexus::artifact {
		'deployit-cli' :
			gav 		=> "com.xebialabs.deployit:deployit:${version}",
			classifier 	=> 'cli',
			packaging 	=> 'zip',
			repository 	=> "releases",
			output 		=> "${tmpdir}/deployit-${version}-cli.zip",
			ensure 		=> $manage_files,
			require 	=> [Class["nexus"],File["${tmpdir}"]]
	}
		
   
}
	
if $install == "files" {
	  
 	file {"deployit-${version}-cli.zip":
   		   ensure => $manage_files,
   	   	   path => "${tmpdir}/deployit-${version}-cli.zip",
      	   require => File["${tmpdir}"],
      	   source => "$install_filesource/deployit-${version}-cli.zip",
      	   before => Exec["unpack deployit_cli-cli"]
      	   	}	  
}

	
	
	
exec{
	 "unpack deployit_cli-cli":
		command 	=> "/usr/bin/unzip ${tmpdir}/deployit-${version}-cli.zip",
		cwd 		=> "${basedir}",
		creates 	=> "${basedir}/deployit-${version}-cli",
		require 	=> $install ?{
				default => File["${basedir}","deployit-${version}-cli.zip"],
				'nexus' => [File["${basedir}"], Nexus::Artifact["deployit-cli"]],
				},
		user		=>	"${install_owner}",
		}

file{
	"${homedir}/cli":
		ensure 		=> $manage_link,
		target 		=> "${basedir}/deployit-${version}-cli",
		require 	=> Exec["unpack deployit-cli"],
		owner		=> "${install_owner}",
		group		=> "${install_group}"
	}						
}
	
	
	
	
	
	
	


