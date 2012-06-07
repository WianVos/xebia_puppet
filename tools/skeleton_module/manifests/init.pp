#
#
class skeleton(
	$packages 			= $skeleton::params::packages, 
	$version 			= $skeleton::params::version,
	$basedir 			= $skeleton::params::basedir,
	$homedir 			= $skeleton::params::homedir,
	$tmpdir				= $skeleton::params::tmpdir,
	$absent 			= $skeleton::params::absent,
	$disabled 			= $skeleton::params::disabled,
	$ensure				= $skeleton::params::ensure,
	$install			= $skeleton::params::install,
	$install_filesource	= $skeleton::params::install_filesource,
	$install_owner		= $skeleton::params::install_owner,
	$install_group		= $skeleton::params::install_group,
	$install_source_url	= $skeleton::params::install_source_url
		
) inherits skeleton::params{
	
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
	
	#install packages as needed by skeleton	
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
	
	#Setup the xebia_puppet infrstructure when intergrate is set to true
	if $intergrate == true {
		class{$intergration_classes:}
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
			url => "${skeleton::params::nexus_url}",
			username => "${skeleton::params::nexus_user}",
			password => "${skeleton::params::nexus_password}"
	}
	
		
    nexus::artifact {
		'skeleton' :
			gav 		=> "com.xebialabs.skeleton:skeleton:${version}",
			classifier 	=> 'server',
			packaging 	=> 'zip',
			repository 	=> "releases",
			output 		=> "${tmpdir}/skeleton-${version}-server.zip",
			ensure 		=> $manage_files,
			require 	=> [Class["nexus"],File["${tmpdir}"]]
		}
	
	exec{
	"unpack skeleton":
		command 	=> "/usr/bin/unzip ${tmpdir}/skeleton-${version}.zip",
		cwd 		=> "${basedir}",
		creates 	=> "${basedir}/skeleton-${version}",
		require 	=> [File["${basedir}"], Nexus::Artifact["skeleton"]],		
		user		=> "${install_owner}",
		}
	
}
	
if $install == "files" {
	  
    file {"skeleton-${version}.zip":
   		   ensure => $manage_files,
   	   	   path => "${tmpdir}/skeleton-${version}.zip",
      	   require => File["${tmpdir}"],
      	   source => "$install_filesource/skeleton-${version}.zip",
      	   before => Exec["unpack skeleton"]
        }
        
    exec{
	"unpack skeleton":
		command 	=> "/usr/bin/unzip ${tmpdir}/skeleton-${version}.zip",
		cwd 		=> "${basedir}",
		creates 	=> "${basedir}/skeleton-${version}",
		require 	=> File["${basedir}","skeleton-${version}.zip"],
		user		=> "${install_owner}",
		}
    
}

if $install == "source" {
	
	common::source{"skeleton-${version}.zip":
		source_url 	=>  "${install_source_url}",
        target 		=>	"${basedir}",
		type		=>	"zip",
		owner		=> 	"${install_owner}",				
	}
	
}

	
	
	

	


file{
	"${homedir}/skeleton":
		ensure 		=> $manage_link,
		target 		=> "${basedir}/skeleton-${version}-server",
		require		=> $install ? {
				nexus	=>	Exec["unpack skeleton"],
				files	=>	Exec["unpack skeleton"],
				source	=> 	Common::Source["skeleton-${version}.zip"],
				default =>	Exec["unpack skeleton"],
				},
		owner		=> "${install_owner}",
		group		=> "${install_group}"
	}	



#file{
#	"init script":
#		ensure 		=> $manage_files,
#		source 		=> "",
#		path		=> "/etc/init.d/skeleton",
#		owner		=> root,
#		group		=> root,
#		mode		=> 700,
#}

#file{
#	"skeleton config file":
#		ensure 		=> $manage_files,
#		source 		=> "$install_filesource/skeleton.conf",
#		path		=> "${basedir}/skeleton-${version}-server/conf/skeleton.conf",
#		owner		=> "${install_owner}",
#		group		=> "${install_group}",
#		require 	=> [Exec["unpack skeleton-server"],File["${homedir}/server"]],
#		mode		=> 700,
#		notify		=> Service["skeleton"]
#}
#
#
#exec{
#	"init skeleton":
#		creates		=> "${homedir}/server/repository",
#		command		=> "${homedir}/server/bin/server.sh -setup -reinitialize -force",
#		user		=> "${install_owner}",
#		require		=> [Exec["unpack skeleton-server"],File["${homedir}/server"]],
#		logoutput	=> true,
#		 
#}

service{
	'skeleton':
		require 	=> [File["${homedir}/server","skeleton config file"],Exec["init skeleton"]],
		ensure		=> "${ensure_service}",
		hasrestart	=> true,
	}		
}
	
	
	
	
	
	
	


