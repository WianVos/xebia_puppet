#
#
class deployit(
	$packages 			= $deployit::params::packages, 
	$version 			= $deployit::params::version,
	$basedir 			= $deployit::params::basedir,
	$homedir 			= $deployit::params::homedir,
	$tmpdir				= $deployit::params::tmpdir,
	$absent 			= $deployit::params::absent,
	$disabled 			= $deployit::params::disabled,
	$ensure				= $deployit::params::ensure,
	$install			= $deployit::params::install,
	$install_filesource	= $deployit::params::install_filesource,
	$install_owner		= $deployit::params::install_owner,
	$install_group		= $deployit::params::install_group
	
		
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
if $install == "nexus" {	
    class {
		'nexus' :
			url => "${deployit::params::nexus_url}",
			username => "${deployit::params::nexus_user}",
			password => "${deployit::params::nexus_password}"
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
		
    nexus::artifact {
		'deployit-server' :
			gav 		=> "com.xebialabs.deployit:deployit:${version}",
			classifier 	=> 'server',
			packaging 	=> 'zip',
			repository 	=> "releases",
			output 		=> "${tmpdir}/deployit-${version}-server.zip",
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
				'nexus' => [File["${basedir}"], Nexus::Artifact["deployit-cli"]],
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
				'nexus' => [File["${basedir}"], Nexus::Artifact["deployit-server"]],
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
		source 		=> "$install_filesource/deployit.conf",
		path		=> "${basedir}/deployit-${version}-server/conf/deployit.conf",
		owner		=> "${install_owner}",
		group		=> "${install_group}",
		require 	=> [Exec["unpack deployit-server"],File["${homedir}/server"]],
		mode		=> 700,
}

file{
	"deployit init_script":
		ensure 		=> $manage_files,
		content 	=> template("deployit/deployit_init.sh.erb"),
		path		=> "${homedir}/deployit-${version}-server/bin/deployit_init.sh",
		owner		=> "${install_owner}",
		group		=> "${install_group}",
		require 	=> [Exec["unpack deployit-server"],File["deployit config file","${homedir}/server"]],
		mode		=> 700,		
}

exec{
	"init deployit":
		creates		=> "${homedir}/server/repository",
		command		=> "${homedir}/server/bin/deployit_init.sh",
		user		=> "${install_owner}",
		require		=> [Exec["unpack deployit-server"],File["deployit init_script"]],
		logoutput	=> true,
		 
}

service{
	'deployit':
		require 	=> [File["${homedir}/server","deployit config file"],Exec["init deployit"]],
		ensure		=> "${ensure_service}",
		hasrestart	=> true,
	}		
}
	
	
	
	
	
	
	


