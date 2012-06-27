#
#
class splunk(
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
	$universe				= params_lookup('universe', 'global'),
	$application				= params_lookup('application', 'global'),
	$customer				= params_lookup('customer', 'global'),
	
		
) inherits splunk::params{
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
	
	
	
	#install packages as needed by splunk	
	#we user extra packages from xebia_common
	xebia_common::features::extra_package{$packages:
		ensure	=> "${manage_package}"
	}
	
	#create the needed users
	group {
	"$install_group" :
		ensure => $manage_user,
	}
	user {
	"$install_owner" :
		ensure => "${manage_user}",
		gid => "${install_group}",
		managehome => true,
		system => true,
	}
	file {
	"${install_owner} profile" :
		content => template('splunk/user_profile.erb'),
		path => "/home/${install_owner}/.profile",
		mode => "0770",
		owner => "${install_owner}",
		group => "${install_group}",
		ensure => "${manage_files}",
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
			before => Exec["unpack splunk"]
	}
	exec {
		"unpack splunk" :
			command =>
			"/bin/tar -xzf ${tmpdir}/${puppetfiles_tarfile}",
			cwd => "${basedir}",
			creates => "${basedir}/splunk/bin",
			require => File["${basedir}", "${puppetfiles_tarfile}"],
			user => "${install_owner}",
			logoutput => true,
	}
	file {
		"${homedir}/etc" :
			ensure => $manage_directory,
			owner => "${install_owner}",
			group => "${install_group}",
			require => Exec["unpack splunk"]
	}
}

# init splunk 
	exec {'splunk_init':
			command => "${homedir}/bin/splunk start --accept-license --no-prompt --answer-yes > ${markerdir}/${name}.txt",
			creates => "${markerdir}/${name}.txt",
			require => File["${homedir}/etc"] 
		}
# create startup script 	
	exec{'boot_start':
			command => "${homedir}/bin/splunk enable boot-start"
                        creates => "/etc/init.d/splunk",
                        require => Exec["splunk_init"]
# service 
	service{'splunk':
			require => 

	
}



