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
	
	# setup the concat module for later use
	include concat::setup
	
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
	#we user extra packages from xebia_common
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
			system 		=> true,
	}
	
	#setup infra 
	# all these directory's should be owned by root
	file {["${infra_dir}","${marker_dir}","${script_dir}","${config_dir}"]:
		ensure 	=> "${manage_directory}",
		owner  	=> root,
		group	=> root,
		mode	=> 770,
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
	#datadir
	file {"${datadir}":
		ensure 	=> "${manage_directory}",
		owner 	=> "${install_owner}",
		group	=> "${install_group}"
	}
	
	
#download and unpack the needed files into the temporary directory in accordance with the installation type
# cli is downloaded always 
# server in downloaded only if installation type is set to server

# puppetfiles . installation based on files included in the module	
if $install == "puppetfiles" {
	file {
		"postgresql_${version}_ubuntu.tar.gz" :
			ensure => $manage_files,
			path => "${tmpdir}/postgresql_${version}_ubuntu.tar.gz",
			require => File["${tmpdir}"],
			source =>
			"puppet:///modules/postgresql/install_tar/postgresql_9_1_2_ubuntu.tar.gz", 
			before => Exec["unpack postgresql"]
	}
	exec {
		"unpack postgresql" :
			command =>
			"/bin/tar -xzf ${tmpdir}/postgresql_${version}_ubuntu.tar.gz ",
			cwd => "${basedir}",
			creates => "${basedir}/postgresql/bin",
			require => File["${basedir}", "postgresql_${version}_ubuntu.tar.gz"],
			user => "${install_owner}",
			logoutput => true,
	}
	file {
		"${homedir}/etc" :
			ensure => $manage_directory,
			owner => "${install_owner}",
			group => "${install_group}",
			require => Exec["unpack postgresql"]
	}
}
#initialize the database_cluster
exec {
	"initdb ${datadir}" :
		command => "${homedir}/bin/initdb -D ${datadir}",
		user => "${install_owner}",
		require	=> [Exec["unpack postgresql"],File["${datadir}"]],
		creates => "${datadir}/PG_VERSION"
}
#install service script in /etc/init.d
file {'postgresql service script':
		ensure => "${manage_files}",
		content => template('postgresql/postgresql.sh.erb'),
		mode	=> "0750",
		require => Exec["unpack postgresql"],
		path	=> "/etc/init.d/postgresql"
	}

#setup config 
concat{"${datadir}/postgresql.conf":
	owner => "${install_owner}",
	group => "${install_group}",
	mode  => "0770",
	ensure => "${manage_files}",
	notify => Service["postgresql"]
}	

concat::fragment{"baseconfig":
      target => "${datadir}/postgresql.conf",
      content => inline_template("<% postgresConfBaseOptions.sort_by {|key, value| key}.each do |key, value| %><%= key %> = <%= value %> \n<% end %>"),
      order   => 01,
   }

#run the service
service {
	'postgresql' :
		require => [Exec["initdb ${datadir}"],File['postgresql service script']],
		ensure => "${manage_service}",
		hasrestart => true,
	}
}
	
	
	
	
	
	
	


