#
#
class deployit(
	$packages 			= $jetty::params::packages, 
	$version 			= $jetty::params::version,
	$basedir 			= $jetty::params::basedir,
	$homedir 			= $jetty::params::homedir,
	$tmpdir				= $jetty::params::tmpdir,
	$absent 			= $jetty::params::absent,
	$disabled 			= $jetty::params::disabled,
	$ensure				= $jetty::params::ensure,
	$install			= $jetty::params::install,
	$install_filesource	= $jetty::params::install_filesource,
	$install_owner		= $jetty::params::install_owner,
	$install_group		= $jetty::params::install_group
	
		
) inherits jetty::params{
	
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
	
	#install packages as needed by jetty	
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
			url => "${jetty::params::nexus_url}",
			username => "${jetty::params::nexus_user}",
			password => "${jetty::params::nexus_password}"
	}
	
	nexus::artifact {
		'jetty-cli' :
			gav 		=> "com.xebialabs.jetty:jetty:${version}",
			classifier 	=> 'cli',
			packaging 	=> 'zip',
			repository 	=> "releases",
			output 		=> "${tmpdir}/jetty-${version}-cli.zip",
			ensure 		=> $manage_files,
			require 	=> [Class["nexus"],File["${tmpdir}"]]
	}
		
    nexus::artifact {
		'jetty-server' :
			gav 		=> "com.xebialabs.jetty:jetty:${version}",
			classifier 	=> 'server',
			packaging 	=> 'zip',
			repository 	=> "releases",
			output 		=> "${tmpdir}/jetty-${version}-server.zip",
			ensure 		=> $manage_files,
			require 	=> [Class["nexus"],File["${tmpdir}"]]
		}
	}
	
if $install == "files" {
	  
 	file {"jetty-${version}-cli.zip":
   		   ensure => $manage_files,
   	   	   path => "${tmpdir}/jetty-${version}-cli.zip",
      	   require => File["${tmpdir}"],
      	   source => "$install_filesource/jetty-${version}-cli.zip",
      	   before => Exec["unpack jetty-cli"]
      	   	}	  
    
    
    file {"jetty-${version}-server.zip":
   		   ensure => $manage_files,
   	   	   path => "${tmpdir}/jetty-${version}-server.zip",
      	   require => File["${tmpdir}"],
      	   source => "$install_filesource/jetty-${version}-server.zip",
      	   before => Exec["unpack jetty-server"]
        }
}

	
	
	
exec{
	 "unpack jetty-cli":
		command 	=> "/usr/bin/unzip ${tmpdir}/jetty-${version}-cli.zip",
		cwd 		=> "${basedir}",
		creates 	=> "${basedir}/jetty-${version}-cli",
		require 	=> $install ?{
				default => File["${basedir}","jetty-${version}-cli.zip"],
				'nexus' => [File["${basedir}"], Nexus::Artifact["jetty-cli"]],
				},
		user		=>	"${install_owner}",
		}
	

exec{
	"unpack jetty-server":
		command 	=> "/usr/bin/unzip ${tmpdir}/jetty-${version}-server.zip",
		cwd 		=> "${basedir}",
		creates 	=> "${basedir}/jetty-${version}-server",
		require 	=> $install ? {
				default => File["${basedir}","jetty-${version}-server.zip"],
				'nexus' => [File["${basedir}"], Nexus::Artifact["jetty-server"]],
				},
		user		=> "${install_owner}",
		}

file{
	"${homedir}/cli":
		ensure 		=> $manage_link,
		target 		=> "${basedir}/jetty-${version}-cli",
		require 	=> Exec["unpack jetty-cli"],
		owner		=> "${install_owner}",
		group		=> "${install_group}"
	}				

file{
	"${homedir}/server":
		ensure 		=> $manage_link,
		target 		=> "${basedir}/jetty-${version}-server",
		require 	=> Exec["unpack jetty-server"],
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
		source 		=> "$install_filesource/jetty-initd.sh",
		path		=> "/etc/init.d/jetty",
		owner		=> root,
		group		=> root,
		mode		=> 700,
}

file{
	"jetty config file":
		ensure 		=> $manage_files,
		source 		=> "$install_filesource/jetty.conf",
		path		=> "${basedir}/jetty-${version}-server/conf/jetty.conf",
		owner		=> "${install_owner}",
		group		=> "${install_group}",
		require 	=> [Exec["unpack jetty-server"],File["${homedir}/server"]],
		mode		=> 700,
		notify		=> Service["jetty"]
}


exec{
	"init jetty":
		creates		=> "${homedir}/server/repository",
		command		=> "${homedir}/server/bin/server.sh -setup -reinitialize -force",
		user		=> "${install_owner}",
		require		=> [Exec["unpack jetty-server"],File["${homedir}/server"]],
		logoutput	=> true,
		 
}

service{
	'jetty':
		require 	=> [File["${homedir}/server","jetty config file"],Exec["init jetty"]],
		ensure		=> "${ensure_service}",
		hasrestart	=> true,
	}		
}
	
	
	
	
	
	
	


