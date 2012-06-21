#
#
class postgresql(
	$packages 			= params_lookup('packages'), 
	$version 			= params_lookup('version'),
	#$basedir 			= params_lookup('basedir'),
	#$homedir 			= params_lookup('homedir'),
	#$tmpdir				= params_lookup('tmpdir'),
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
			managehome 	=> false,
			home 		=> "${homedir}",
			system 		=> true,
			
	}
	#setup infra 
	file {["${infra_dir}","${marker_dir}","${script_dir}","${config_dir}"]:
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
if $install == "nexus" {	
    class {
		'nexus' :
			url => "${postgresql::params::nexus_url}",
			username => "${postgresql::params::nexus_user}",
			password => "${postgresql::params::nexus_password}"
	}
	
		
    nexus::artifact {
		'postgresql' :
			gav 		=> "com.xebialabs.postgresql:postgresql:${version}",
			classifier 	=> 'server',
			packaging 	=> 'zip',
			repository 	=> "releases",
			output 		=> "${tmpdir}/postgresql-${version}-server.zip",
			ensure 		=> $manage_files,
			require 	=> [Class["nexus"],File["${tmpdir}"]]
		}
	
	exec{
	"unpack postgresql":
		command 	=> "/usr/bin/unzip ${tmpdir}/postgresql-${version}.zip",
		cwd 		=> "${basedir}",
		creates 	=> "${basedir}/postgresql-${version}",
		require 	=> [File["${basedir}"], Nexus::Artifact["postgresql"]],		
		user		=> "${install_owner}",
		}
	
}
	
if $install == "files" {
	  
    file {"postgresql-${version}.zip":
   		   ensure => $manage_files,
   	   	   path => "${tmpdir}/postgresql-${version}.zip",
      	   require => File["${tmpdir}"],
      	   source => "$install_filesource/postgresql-${version}.zip",
      	   before => Exec["unpack postgresql"]
        }
        
    exec{
	"unpack postgresql":
		command 	=> "/usr/bin/unzip ${tmpdir}/postgresql-${version}.zip",
		cwd 		=> "${basedir}",
		creates 	=> "${basedir}/postgresql-${version}",
		require 	=> File["${basedir}","postgresql-${version}.zip"],
		user		=> "${install_owner}",
		}
    
}

if $install == "source" {
	
	common::source{"postgresql-${version}.zip":
		source_url 	=>  "${install_source_url}",
        target 		=>	"${basedir}",
		type		=>	"zip",
		owner		=> 	"${install_owner}",				
	}
	
}

	
	
	

	


file{
	"${homedir}/postgresql":
		ensure 		=> $manage_link,
		target 		=> "${basedir}/postgresql-${version}-server",
		require		=> $install ? {
				nexus	=>	Exec["unpack postgresql"],
				files	=>	Exec["unpack postgresql"],
				source	=> 	Common::Source["postgresql-${version}.zip"],
				default =>	Exec["unpack postgresql"],
				},
		owner		=> "${install_owner}",
		group		=> "${install_group}"
	}	



#file{
#	"init script":
#		ensure 		=> $manage_files,
#		source 		=> "",
#		path		=> "/etc/init.d/postgresql",
#		owner		=> root,
#		group		=> root,
#		mode		=> 700,
#}

#file{
#	"postgresql config file":
#		ensure 		=> $manage_files,
#		source 		=> "$install_filesource/postgresql.conf",
#		path		=> "${basedir}/postgresql-${version}-server/conf/postgresql.conf",
#		owner		=> "${install_owner}",
#		group		=> "${install_group}",
#		require 	=> [Exec["unpack postgresql-server"],File["${homedir}/server"]],
#		mode		=> 700,
#		notify		=> Service["postgresql"]
#}
#
#
#exec{
#	"init postgresql":
#		creates		=> "${homedir}/server/repository",
#		command		=> "${homedir}/server/bin/server.sh -setup -reinitialize -force",
#		user		=> "${install_owner}",
#		require		=> [Exec["unpack postgresql-server"],File["${homedir}/server"]],
#		logoutput	=> true,
#		 
#}

service{
	'postgresql':
		require 	=> [File["${homedir}/server","postgresql config file"],Exec["init postgresql"]],
		ensure		=> "${ensure_service}",
		hasrestart	=> true,
	}		
}
	
	
	
	
	
	
	


