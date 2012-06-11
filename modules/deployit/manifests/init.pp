class deployit(
	$packages 					= params_lookup('packages, 
	$version 					= params_lookup('version,
	$basedir 					= params_lookup('basedir,
	$homedir 					= params_lookup('homedir,
	$tmpdir						= params_lookup('tmpdir,
	$absent 					= params_lookup('absent,
	$disabled 					= params_lookup('disabled,
	$ensure						= params_lookup('ensure,
	$install					= params_lookup('install,
	$install_filesource			= params_lookup('install_filesource,
	$install_owner				= params_lookup('install_owner,
	$install_group				= params_lookup('install_group,
	$intergrate					= params_lookup('intergrate,
	$intergration_classes		= params_lookup('intergration_classes,
	$admin_password				= params_lookup('admin_password,
	$jcr_repository_path		= params_lookup('jcr_repository_path,
	$threads_min				= params_lookup('threads_min,
	$threads_max				= params_lookup('threads_max,
	$ssl						= params_lookup('ssl,
	$http_bind_address			= params_lookup('http_bind_address,
	$http_context_root			= params_lookup('http_context_root,
	$http_port					= params_lookup('http_port,
	$importable_packages_path	= params_lookup('importable_packages_path,
	$xebia_universe				= params_lookup('xebia_universe,
	$plugin_install				= params_lookup('plugin_install
		
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
	
	
	
	
	#xebia_puppet intergration stuff
	if $intergrate == true {
		class{"xebia_common::regdir":}
		
		@@xebia_common::features::export_facts{"deployit_facts_${::hostname}":
			options => { "deployit_hostname" 	=> "${::fqdn}",
						 "deployit_ipaddress" 	=> "${::ipaddress}",
						 "deployit_user"		=> "admin",
						 "deployit_password"	=> "${admin_password}",
						 "deployit_port"		=>	"${http_port}"
						},
			tag		=> ["${xebia_universe}-deployit-service"]
		}
		
		@@xebia_common::features::export_config{"deployit_config.sh":
			options => { "deployit_hostname" 	=> "${::fqdn}",
						 "deployit_ipaddress" 	=> "${::ipaddress}",
						 "deployit_user"		=> "admin",
						 "deployit_password"	=> "${admin_password}",
						 "deployit_port"		=>	"${http_port}"
						},
			confdir =>	"${xebia_common::regdir::configDir}",
			tag		=> ["${xebia_universe}-deployit-service-config"]
		}
		
		Xebia_common::Features::Export_facts <<| |>>
		Xebia_common::Features::Export_config <<| |>>
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
		content 	=> template("deployit/deployit.conf.erb"),
		path		=> "${basedir}/deployit-${version}-server/conf/deployit.conf",
		owner		=> "${install_owner}",
		group		=> "${install_group}",
		require 	=> [Exec["unpack deployit-server"],File["${homedir}/server"]],
		mode		=> 700,
		notify		=> Service["deployit"],
		replace		=> false
}
if $plugin_install == "true" {

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


exec{
	"init deployit":
		creates		=> "${homedir}/server/repository",
		command		=> "${homedir}/server/bin/server.sh -setup -reinitialize -force",
		user		=> "${install_owner}",
		require		=> [Exec["unpack deployit-server"],File["${homedir}/server","deployit config file"]],
		logoutput	=> true,
		 
}

#export facts

service{
	'deployit':
		require 	=> [File["${homedir}/server","deployit config file"],Exec["init deployit"]],
		ensure		=> "${ensure_service}",
		hasrestart	=> true,
	}
	
	
}
	
	
	
	
	
	
	


