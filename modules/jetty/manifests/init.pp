#
#
class jetty(
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
	$install_group		= $jetty::params::install_group,
	$install_source_url	= $jetty::params::install_source_url
		
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

	
if $install == "files" {
	  
    file {"jetty-${version}.zip":
   		   ensure => $manage_files,
   	   	   path => "${tmpdir}/jetty-${version}.zip",
      	   require => File["${tmpdir}"],
      	   source => "$install_filesource/jetty-${version}.zip",
      	   before => Exec["unpack jetty"]
        }
        
    exec{
	"unpack_jetty":
		command 	=> "/usr/bin/unzip ${tmpdir}/jetty-${version}.zip",
		cwd 		=> "${basedir}",
		creates 	=> "${basedir}/jetty-${version}",
		require 	=> File["${basedir}","jetty-${version}.zip"],
		user		=> "${install_owner}",
		}
    $basetarget = "${basedir}/jetty-${version}"
}

if $install == "source" {
	
	common::source{"unpack_jetty":
		source_url 	=>  "${install_source_url}",
        target 		=>	"${basedir}",
		type		=>	"targz",
		owner		=> 	"${install_owner}",				
	}
	
	$basetarget = "${basedir}/jetty-distribution-${version}"
}


file{
	"${homedir}/jetty":
		ensure 		=> $manage_link,
		target 		=> "${basetarget}",
		require		=> $install ? {
				files	=>	Exec["unpack_jetty"],
				source	=> 	Common::Source["unpack_jetty"],
				default =>	Exec["unpack_jetty"],
				},
		owner		=> "${install_owner}",
		group		=> "${install_group}"
	}	


#file{
#	"init script":
#		ensure 		=> $manage_files,
#		source 		=> "",
#		path		=> "/etc/init.d/jetty",
#		owner		=> root,
#		group		=> root,
#		mode		=> 700,
#}

#file{
#	"jetty config file":
#		ensure 		=> $manage_files,
#		source 		=> "$install_filesource/jetty.conf",
#		path		=> "${basedir}/jetty-${version}-server/conf/jetty.conf",
#		owner		=> "${install_owner}",
#		group		=> "${install_group}",
#		require 	=> [Exec["unpack jetty-server"],File["${homedir}/server"]],
#		mode		=> 700,
#		notify		=> Service["jetty"]
#}
#
#
#exec{
#	"init jetty":
#		creates		=> "${homedir}/server/repository",
#		command		=> "${homedir}/server/bin/server.sh -setup -reinitialize -force",
#		user		=> "${install_owner}",
#		require		=> [Exec["unpack jetty-server"],File["${homedir}/server"]],
#		logoutput	=> true,
#		 
#}

service{
	'jetty':
		require 	=> File["${homedir}/jetty"],
		ensure		=> "${ensure_service}",
		hasrestart	=> true,
	}		
}
