#
#
class deployit(
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
	$install_group		= $skeleton::params::install_group
	
		
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
		'skeleton-cli' :
			gav 		=> "com.xebialabs.skeleton:skeleton:${version}",
			classifier 	=> 'cli',
			packaging 	=> 'zip',
			repository 	=> "releases",
			output 		=> "${tmpdir}/skeleton-${version}-cli.zip",
			ensure 		=> $manage_files,
			require 	=> [Class["nexus"],File["${tmpdir}"]]
	}
		
    nexus::artifact {
		'skeleton-server' :
			gav 		=> "com.xebialabs.skeleton:skeleton:${version}",
			classifier 	=> 'server',
			packaging 	=> 'zip',
			repository 	=> "releases",
			output 		=> "${tmpdir}/skeleton-${version}-server.zip",
			ensure 		=> $manage_files,
			require 	=> [Class["nexus"],File["${tmpdir}"]]
		}
	}
	
if $install == "files" {
	  
 	file {"skeleton-${version}-cli.zip":
   		   ensure => $manage_files,
   	   	   path => "${tmpdir}/skeleton-${version}-cli.zip",
      	   require => File["${tmpdir}"],
      	   source => "$install_filesource/skeleton-${version}-cli.zip",
      	   before => Exec["unpack skeleton-cli"]
      	   	}	  
    
    
    file {"skeleton-${version}-server.zip":
   		   ensure => $manage_files,
   	   	   path => "${tmpdir}/skeleton-${version}-server.zip",
      	   require => File["${tmpdir}"],
      	   source => "$install_filesource/skeleton-${version}-server.zip",
      	   before => Exec["unpack skeleton-server"]
        }
}

	
	
	
exec{
	 "unpack skeleton-cli":
		command 	=> "/usr/bin/unzip ${tmpdir}/skeleton-${version}-cli.zip",
		cwd 		=> "${basedir}",
		creates 	=> "${basedir}/skeleton-${version}-cli",
		require 	=> $install ?{
				default => File["${basedir}","skeleton-${version}-cli.zip"],
				'nexus' => [File["${basedir}"], Nexus::Artifact["skeleton-cli"]],
				},
		user		=>	"${install_owner}",
		}
	

exec{
	"unpack skeleton-server":
		command 	=> "/usr/bin/unzip ${tmpdir}/skeleton-${version}-server.zip",
		cwd 		=> "${basedir}",
		creates 	=> "${basedir}/skeleton-${version}-server",
		require 	=> $install ? {
				default => File["${basedir}","skeleton-${version}-server.zip"],
				'nexus' => [File["${basedir}"], Nexus::Artifact["skeleton-server"]],
				},
		user		=> "${install_owner}",
		}

file{
	"${homedir}/cli":
		ensure 		=> $manage_link,
		target 		=> "${basedir}/skeleton-${version}-cli",
		require 	=> Exec["unpack skeleton-cli"],
		owner		=> "${install_owner}",
		group		=> "${install_group}"
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
		source 		=> "$install_filesource/skeleton.conf",
		path		=> "${basedir}/skeleton-${version}-server/conf/skeleton.conf",
		owner		=> "${install_owner}",
		group		=> "${install_group}",
		require 	=> [Exec["unpack skeleton-server"],File["${homedir}/server"]],
		mode		=> 700,
		notify		=> Service["skeleton"]
}


exec{
	"init skeleton":
		creates		=> "${homedir}/server/repository",
		command		=> "${homedir}/server/bin/server.sh -setup -reinitialize -force",
		user		=> "${install_owner}",
		require		=> [Exec["unpack skeleton-server"],File["${homedir}/server"]],
		logoutput	=> true,
		 
}

service{
	'skeleton':
		require 	=> [File["${homedir}/server","skeleton config file"],Exec["init skeleton"]],
		ensure		=> "${ensure_service}",
		hasrestart	=> true,
	}		
}
	
	
	
	
	
	
	


