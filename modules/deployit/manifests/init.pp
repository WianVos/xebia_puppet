#
#
class deployit(
	$packages 		= $deployit::params::packages, 
	$version 		= $deployit::params::version,
	$basedir 		= $deployit::params::basedir,
	$homedir 		= $deployit::params::homedir,
	$tmpdir			= $deployit::params::tmpdir,
	$absent 		= $deployit::params::absent,
	$disabled 		= $deployit::params::disabled,
	$install		= $deployit::params::install,
	$install_owner	= $deployit::params::install_owner,
	$install_group	= $deployit::params::install_group
	
		
) inherits deployit::params{
	
	#set various manage parameters in accordance to the $absent directive
	$manage_package = $absent ? {
		true => "absent",
		false => "installed",
		default => "installed"
	}
	
	$manage_directory = $absent ? {
		true => "absent",
		default => "directory",
	}
	
	$manage_link = $absent ? {
		true => "absent",
		default => "link",
	}
	
	$manage_nexus = $absent ? {
		true => "absent",
		false => "present",
		default => "present"
	}
	
	#install packages as needed by deployit	
	package{$packages:
		ensure => $manage_package
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
			ensure 		=> $manage_nexus,
			require 	=> [Class["nexus"],File["${tmpdir}"]]
	}
	
	exec{
		"unpack deployit-cli":
			command 	=> "/usr/bin/unzip ${tmpdir}/deployit-${version}-cli.zip",
			cwd 		=> "${basedir}",
			creates 	=> "${basedir}/cli",
			require 	=> [File["${basedir}"], Nexus::Artifact["deployit-cli"]]
	}
	
  	if $install == "server" {
    	
    	nexus::artifact {
			'deployit-server' :
				gav 		=> "com.xebialabs.deployit:deployit:${version}",
				classifier 	=> 'server',
				packaging 	=> 'zip',
				repository 	=> "releases",
				output 		=> "${tmpdir}/deployit-${version}-server.zip",
				ensure 		=> $manage_nexus,
				require 	=> [Class["nexus"],File["${tmpdir}"]]
		}
		
		exec{
			"unpack deployit-server":
			command 	=> "/usr/bin/unzip ${tmpdir}/deployit-${version}-server.zip",
			cwd 		=> "${basedir}",
			creates 	=> "${basedir}/cli",
			require 	=> [File["${basedir}"], Nexus::Artifact["deployit-server"]]
		}
		
    }
	
	
	
	
	
	
	
}

