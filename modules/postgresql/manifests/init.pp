#
#
class postgresql(
	$packages 			= params_lookup('packages'), 
	$version 			= params_lookup('version'),
	$basedir 			= params_lookup('basedir'),
	$homedir 			= params_lookup('homedir'),
	$tmpdir				= params_lookup('tmpdir'),
	$datadir			= params_lookup('datadir'),
	$absent 			= params_lookup('absent'),
	$ensure				= params_lookup('ensure'),
	$disabled 			= params_lookup('disabled'),
	$ensure				= params_lookup('ensure,'),
	$install			= params_lookup('install'),
	$install_owner			= params_lookup('install_owner'),
	$install_group			= params_lookup('install_group'),
	$confdir					= params_lookup('confdir'),
	$scriptdir					= params_lookup('scriptdir'),
	$markerdir					= params_lookup('markerdir'),
	$import_facts				= params_lookup('import_facts'),
	$import_config				= params_lookup('import_config'),
	$export_facts				= params_lookup('export_facts'),
	$export_config				= params_lookup('export_config'),
	$universe				= params_lookup('universe'),
	$facts_import_tags		= params_lookup('facts_import_tags')
	
	
		
) inherits postgresql::params{
	
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
	

	$manage_service = $ensure ? {
		true	=> "running",
		false 	=> "stoppped",
		default	=> "running"
	}
	
	
	
	#install packages as needed by postgresql	
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
			managehome 	=> true,
			system 		=> true,
	}
	
	#setup infra 
	# all these directory's should be owned by root
	file {["${infra_dir}","${marker_dir}","${script_dir}","${config_dir}","{$tmpdir}"]:
		ensure 	=> "${manage_directory}",
		owner  	=> root,
		group	=> root,
		mode	=> 770,
	}
	 
	#extra packages
	xebia_common::features::extra_package{$packages:
		ensure	=> "${manage_package}"
	}
	
	#Setup the xebia_puppet infrstructure when intergrate is set to true
	if $export_facts {
		@@xebia_common::features::export_facts{"postgresql_facts_${::hostname}":
			options => { "postgresql_hostname" 	=> "${::fqdn}",
						 "postgresql_ipaddress" => "${::ipaddress}",
						 },
			tag		=> ["${universe}-postgresql-db-service"]
		}
	}
	
	if $export_config {
		@@xebia_common::features::export_config{"postgresql_facts_${::hostname}":
			options => { "postgresql_hostname" 	=> "${::fqdn}",
						 "postgresql_ipaddress" => "${::ipaddress}",
						 },
			confdir =>	"${config_dir}",
			tag		=> ["${universe}-postgresql-db-service-config"]
		}
	}
	
	if $import_facts {
		Xebia_common::Features::Export_facts <<| |>> 
	}
	if $import_config {
		Xebia_common::Features::Export_config <<| |>>{	confdir	=> "${confdir}" }
		
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

	
if $install == "puppetfiles" {
	  
    file {"postgresql-${version}_ubuntu.tar.gz":
   		   ensure => $manage_files,
   	   	   path => "${tmpdir}/postgresql-${version}_ubuntu.tar.gz",
      	   require => File["${tmpdir}"],
      	   source => "puppet:///modules/postgresql/install_tar/postgresql-${version}.tar.gz",
      	   before => Exec["unpack postgresql"]
        }
        
    exec{
	"unpack postgresql":
		command 	=> "/usr/bin/tar -xzf ${tmpdir}/postgresql-${version}_ubuntu.tar.gz ",
		cwd 		=> "${basedir}",
		creates 	=> "${basedir}/postgresql",
		require 	=> File["${basedir}","postgresql-${version}.tar.gz"],
		user		=> "${install_owner}",
		}
		
	file{"${homedir}/etc":
		ensure => $manage_files,
		owner	=> "${install_owner}",
		group	=> "${install_group}",
		require => Exec["unpack postgresql"]
		}
	}
    


file {"postgresql init script":
			path => "/etc/init.d/postgresql",
			source => template('postgresql.erb'),
			owner	=> "${install_owner}",
			group	=> "${install_group}",
			ensure	=> "${manage_files}",
			mode	=> 0755,
			require => Exec["unpack postgresql"]
			}

Exec {"initdb ${datadir}":
			cmd => "${homedir}/bin/initdb -D ${datadir}",
			user =>	"${install_owner}",
		}





service{
	'postgresql':
		require 	=> [File["postgresql init script"],Exec["initdb ${datadir}"]],
		ensure		=> "${manage_service}",
		hasrestart	=> true,
	}		
}
	
	
	
	
	
	
	


