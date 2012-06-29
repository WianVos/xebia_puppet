#
#
class deployit_cli(
	$packages 					= $deployit_cli::params::packages, 
	$version 					= $deployit_cli::params::version,
	$basedir 					= $deployit_cli::params::basedir,
	$homedir 					= $deployit_cli::params::homedir,
	$tmpdir						= $deployit_cli::params::tmpdir,
	$marker_dir					= $deployit_cli::params::marker_dir,
	$absent 					= $deployit_cli::params::absent,
	$disabled 					= $deployit_cli::params::disabled,
	$ensure						= $deployit_cli::params::ensure,
	$install					= $deployit_cli::params::install,
	$install_filesource			= $deployit_cli::params::install_filesource,
	$install_owner				= $deployit_cli::params::install_owner,
	$install_group				= $deployit_cli::params::install_group,
	$intergrate					= $deployit_cli::params::intergrate,
	$intergration_classes		= $deployit_cli::params::intergration_classes,
	$universe					= params_lookup('universe', 'global'),	
	$conf_dir					= $deployit_cli::params::conf_dir,
	$user_key					= $deployit_cli::params::user_key
	
	
		
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
		
		if $intergration_classes != '' {
			class{$intergration_classes:}
		}
		
		#import deployit settings 
		Xebia_common::Features::Export_config <<| tag == "${universe}-deployit-service-config" |>> { confdir => "${conf_dir}"}
		
		#import deployit settings 
		
			
	}
	
	xebia_common::features::extra_package{$packages:
		ensure	=> "${manage_package}"
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
			managehome 	=> true,
			home 		=> "${homedir}",
			system 		=> true,
			password	=> sha1("deployit")			
	}
	
	ssh_authorized_key {
		"$install_owner key":
			ensure		=> $manage_user,
			key 		=> "${user_key}",
			user 		=> "${install_owner}",
			require		=> User["${install_owner}"],
			type		=> rsa
	}
	
	exec { "deployit sudo":
		command => "/bin/echo \'${install_owner} ALL=(ALL) NOPASSWD:ALL\' >> /etc/sudoers ",
		unless => "/bin/grep ${install_owner} /etc/sudoers",
		require => User["${install_owner}"]
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
	if !defined(Class["xebia_common::regdir"]){
	class{
	"xebia_common::regdir":
		require		=>	File["${homedir}/cli"],
		script_dir	=>	"${script_dir}",
		config_dir	=> "${conf_dir}"
		}

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
      	   require => [File["${tmpdir}"],Xebia_common::Features::Extra_package[$packages]],
      	   source => "$install_filesource/deployit-${version}-cli.zip",
      	   before => Exec["unpack deployit-cli"]
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

file{
	"${homedir}/cli":
		ensure 		=> $manage_link,
		target 		=> "${basedir}/deployit-${version}-cli",
		require 	=> Exec["unpack deployit-cli"],
		owner		=> "${install_owner}",
		group		=> "${install_group}"
	}
	


file {"${script_dir}/$name":
			require 		=> Class["xebia_common::regdir"],
			source 			=> "puppet:///modules/deployit_cli/features/cli_python/",
			sourceselect	=> all,
			recurse 		=> remote,
			owner			=> "${install_owner}",
			group			=> "${install_group}",
			ensure			=> "${manage_files}"
				
		}							
}
	
	
	
	
	
	
	


