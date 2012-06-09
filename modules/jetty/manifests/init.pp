#
#
class jetty(
	$packages 				= $jetty::params::packages, 
	$version 				= $jetty::params::version,
	$basedir 				= $jetty::params::basedir,
	$homedir 				= $jetty::params::homedir,
	$tmpdir					= $jetty::params::tmpdir,
	$absent 				= $jetty::params::absent,
	$disabled 				= $jetty::params::disabled,
	$ensure					= $jetty::params::ensure,
	$install				= $jetty::params::install,
	$install_filesource		= $jetty::params::install_filesource,
	$install_owner			= $jetty::params::install_owner,
	$install_group			= $jetty::params::install_group,
	$install_source_url		= $jetty::params::install_source_url,
	$intergrate				= $jetty::params::intergrate,
	$intergration_classes	= $jetty::params::intergration_classes,
	$xebia_universe			= $jetty::params::xebia_universe
		
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
	
	if $intergrate == true {
		
		if $intergration_classes != '' {
			class{$intergration_classes:}
					}
		
		#import the 
		Xebia_common::Features::Export_facts <<| tag == "${xebia_universe}-jetty-service" |>>
		
		if !defined(Class["deployit_cli"]) {
			deployit_cli::types::jetty_ssh{"jetty instance":
				environments => "${xebia_universe}",
			}
		}
			
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
	
	xebia_common::source{"unpack_jetty":
		source_url 	=>  "${install_source_url}",
        target 		=>	"${basedir}",
		type		=>	"targz",
		owner		=> 	"${install_owner}",	
		group		=>	"${install_group}"			
	}
	
	$basetarget = "${basedir}/jetty-distribution-${version}"
}


  file{
	"${homedir}":
		ensure 		=> $manage_link,
		target 		=> "${basetarget}",
		require		=> $install ? {
				files	=>	Exec["unpack_jetty"],
				source	=> 	Xebia_common::Source["unpack_jetty"],
				default =>	Exec["unpack_jetty"],
				},
		owner		=> "${install_owner}",
		group		=> "${install_group}"
	}	


 

  file { "/var/log/jetty":
    ensure 		=> $manage_link,
    target 		=>"${homedir}/logs",
    require => File["${homedir}"],
    owner		=> "${install_owner}",
  	group		=> "${install_group}"
  	}
  
  file {"/etc/default/jetty":
  	ensure		=> $manage_files,
  	content		=> "JETTY_HOME=\"${$homedir}\"",
  	owner		=> "${install_owner}",
  	group		=> "${install_group}"
  }
  
  file { "/etc/init.d/jetty":
  	ensure 		=> $manage_link,
    target 		=>"${homedir}/bin/jetty.sh",
    require => File["${homedir}"],
  	}
  
  service{
	'jetty':
		require 	=> File["${homedir}","/etc/init.d/jetty","/etc/default/jetty","/var/log/jetty" ],
		ensure		=> "${ensure_service}",
		hasrestart	=> true,
  	}	
  	
}
