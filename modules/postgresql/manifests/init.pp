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
	$facts_import_tags		= params_lookup('facts_import_tags'),
	$pg_pool				= params_lookup('pg_pool'),
	$streaming_replication  = params_lookup('streaming_replication'),
	$sr_role				= params_lookup('sr_role'),
	$streamingReplicationMaster = params_lookup('streamingReplicationMaster'),
	$postgresConfBaseOptions	= params_lookup('postgresConfBaseOptions'),
	$postgresLoggingOptions		= params_lookup('postgresLoggingOptions')
	
		
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
			ensure 		=> "${manage_user}",
			gid 		=> "${install_group}",
			managehome 	=> true,
			system 		=> true,	
	}
	
	file {"${install_owner} keys":
			source 			=> "puppet:///modules/postgresql/keys",
			sourceselect	=> all,
			recurse 		=> remote,
			owner			=> "${install_owner}",
			group			=> "${install_group}",
			ensure			=> "${manage_files}",
			path			=> "/home/${install_owner}/.ssh/",
			mode			=> "0500"	
		}		
			
	ssh_authorized_key {
		"${install_owner} rsa" :
			key =>
			"AAAAB3NzaC1yc2EAAAADAQABAAABAQC0PSfqjNe0YZqMvzlFK34K4h5v8o5jpNIw8vYY9Wa7XA8wFUrDARhlt39On0VvQdTuqNZllu8qeFJS29crDJtGKUhOv5xKlUpaxFBnYvxGF+wF0PW6zlPvYQTAFgseA6JamaQ75ragH+0xumXQzQhrP4P4R7Klzz70haD9QVzDNkwpnqiZVtR4PxjtdsUDkTAFtRq5dTU6pfSDbmXJCiLTdCMyqryqYF5HUHbfmrjrzdhyIyDVywe0u4FOF9U/DxcdXBsvO16oWLYbsRrlubRpCnWzA+m0M2UOLamtCSpRL1NAQ1xEZvvcJUKIe8uRwxbcqyhAvMv3u5lnElcekJqf",
			type => "ssh-rsa",
			user => "${install_owner}"
	}
	file {"${install_owner} profile":
			content => template('postgresql/user_profile.erb'),
			path	=> "/home/${install_owner}/.profile",
			mode	=> "0770",
			owner 	=> "${install_owner}",
			group   => "${install_group}",
     			ensure  => "${manage_files}",
			require => User["${install_owner}"]
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
		"${puppetfiles_tarfile}":
			ensure => $manage_files,
			path => "${tmpdir}/${puppetfiles_tarfile}",
			require => File["${tmpdir}"],
			source =>
			"${puppetfiles_source}",
			before => Exec["unpack postgresql"]
	}
	exec {
		"unpack postgresql" :
			command =>
			"/bin/tar -xzf ${tmpdir}/${puppetfiles_tarfile}",
			cwd => "/",
			creates => "${basedir}/postgresql/bin",
			require => File["${basedir}", "${puppetfiles_tarfile}"],
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
concat {
	"${datadir}/postgresql.conf" :
		owner => "${install_owner}",
		group => "${install_group}",
		mode => "0770",
		notify => Service["postgresql"],
		require => Exec["initdb ${datadir}"]
}
concat::fragment {
	"postgresConfBaseOptions" :
		target => "${datadir}/postgresql.conf",
		content =>
		inline_template("<% postgresConfBaseOptions.sort_by {|key, value| key}.each do |key, value| %><%= key %> = <%= value %> \n<% end %>"),
		order => 01,
}
concat::fragment {
	"postgresLoggingOptions" :
		target => "${datadir}/postgresql.conf",
		content =>
		inline_template("<% postgresLoggingOptions.sort_by {|key, value| key}.each do |key, value| %><%= key %> = <%= value %> \n<% end %>"),
		order => 01,
}

concat {
	"${datadir}/pg_hba.conf":
		owner => "${install_owner}",
		group => "${install_group}",
		notify => Service['postgresql'],
		require => Exec["initdb ${datadir}"],
		mode	=> "0770"
}

concat::fragment {
	"base pg_hba.conf":
		content => template('postgresql/pg_hba.conf.erb'),
		order   => 01,
		target  => "${datadir}/pg_hba.conf"
}

if $streaming_replication == true {
	user {
		"$sr_user" :
			ensure => "${manage_user}",
			gid => "${install_group}",
			managehome => true,
			system => true,
	}
	file {
		"${sr_user} keys" :
			source => "puppet:///modules/postgresql/keys",
			sourceselect => all,
			recurse => remote,
			owner => "${sr_user}",
			group => "${install_group}",
			ensure => "${manage_files}",
			path => "/home/${sr_user}/.ssh/",
			mode => "0500"
	}
	ssh_authorized_key {
		"${sr_user} rsa" :
			key =>
			"AAAAB3NzaC1yc2EAAAADAQABAAABAQC0PSfqjNe0YZqMvzlFK34K4h5v8o5jpNIw8vYY9Wa7XA8wFUrDARhlt39On0VvQdTuqNZllu8qeFJS29crDJtGKUhOv5xKlUpaxFBnYvxGF+wF0PW6zlPvYQTAFgseA6JamaQ75ragH+0xumXQzQhrP4P4R7Klzz70haD9QVzDNkwpnqiZVtR4PxjtdsUDkTAFtRq5dTU6pfSDbmXJCiLTdCMyqryqYF5HUHbfmrjrzdhyIyDVywe0u4FOF9U/DxcdXBsvO16oWLYbsRrlubRpCnWzA+m0M2UOLamtCSpRL1NAQ1xEZvvcJUKIe8uRwxbcqyhAvMv3u5lnElcekJqf",
			type => "ssh-rsa",
			user => "${sr_user}"
	}
	file {
		"${sr_user} profile" :
			content => template('postgresql/user_profile.erb'),
			path => "/home/${sr_user}/.profile",
			mode => "0770",
			owner => "${sr_user}",
			group => "${install_group}",
			ensure => "${manage_files}",
			require => User["${sr_user}"]
	}
	concat::fragment {
	"${sr_user} pg_hba.conf":
		content => "host    all     ${sr_user}        0.0.0.0/0          trust",
		order   => 01,
		target  => "${datadir}/pg_hba.conf"
}
	
	if $sr_role == "master" {
		concat::fragment {
			"streamingReplicationMaster" :
				target => "${datadir}/postgresql.conf",
				content =>
				inline_template("<% streamingReplicationMaster.sort_by {|key, value| key}.each do |key, value| %><%= key %> = <%= value %> \n<% end %>"),
				order => 02,
		}
	}
}


if $pg_pool == true {
	exec {
		"add pgpool_reclass" :
			command =>
			"${homedir}/bin/psql -f ${homedir}/share/contrib/pgpool-regclass.sql template1",
			user => "${install_owner}",
			require => [Service['postgresql']],
			creates => "/opt/postgresql/lib/pgpool-regclass.so"
	}
	file {
		"basebackup.sh" :
			path => "${datadir}/basebackup.sh",
			owner => "${install_owner}",
			group => "${install_group}",
			ensure => "${manage_files}",
			require => Exec["initdb ${datadir}"],
			content => template('postgresql/basebackup.sh.erb')
	}
	file {
		"pgpool_remote_start" :
			path => "${datadir}/pgpool_remote_start",
			owner => "${install_owner}",
			group => "${install_group}",
			ensure => "${manage_files}",
			require => Exec["initdb ${datadir}"],
			content => template('postgresql/pgpool_remote_start.erb')
	}
	file {
		["/var/log/pgpool", "/var/log/pgpool/trigger"] :
			ensure => "${manage_directory}",
			owner => "${install_owner}",
			group => "${install_group}",
			require => Exec["initdb ${datadir}"],
	}
}


#run the service
service {
	'postgresql' :
		require => [Exec["initdb ${datadir}"],File['postgresql service script']],
		ensure => "${manage_service}",
		hasrestart => true,
	}
	
#export the servers settings 
# check if where doing a cluser 
# check if the machine is a master . 
# check if the machine is a slave
	
}
	
	
	
	
	
	
	


