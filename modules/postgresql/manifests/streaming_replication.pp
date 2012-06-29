class postgresql::streaming_replication (
	$sr_user 				= params_lookup('sr_user'),
	$manage_user			= "present",
	$manage_files			= "present",
	$install_group  		= params_lookup('manage_files'),
	$datadir				= params_lookup('datadir'),
	$streaming_replication 	= params_lookup('streaming_replication', 'global'),
	$customer				= params_lookup('customer', 'global'),
	$application			= params_lookup('application', 'global'),
	$universe				= params_lookup('universe', 'global'),
	$install_owner 		= params_lookup("install_owner"),
	$install_group		= params_lookup("install_group"),
	$srSlaveOptions		= params_lookup('srSlaveOptions')
) {
user {
		"${sr_user}" :
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
			path => "/home/${sr_user}/.ss(h/",
			mode => "0600"
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
		"${sr_user} pg_hba.conf" :
			content => "host    all     ${sr_user}        0.0.0.0/0          trust",
			order => 01,
			target => "${datadir}/pg_hba.conf"
	}
	postgresql::user {
		"${sr_user}" :
			ensure => "${manage_user}",
			
	}
	case $streaming_replication {
		'master' : {
			concat::fragment {
				"streamingReplicationMaster" :
					target => "${datadir}/postgresql.conf",
					content =>
					inline_template("<% streamingReplicationMaster.sort_by {|key, value| key}.each do |key, value| %><%= key %> = <%= value %> \n<% end %>"),
					order => 02,
			}
			@@postgresql::export_service_db {
				"postgresql_master_${::hostname}" :
					customer => "${customer}",
					application => "${application}",
					universe => "${universe}",
					use_concat => true,
					concat_target => "${datadir}/recovery.conf",
					concat_options => $srSlaveOptions,
					concat_owner => "${install_owner}",
					concat_group => "${install_group}",
					service => "postgresql",
					role => "master",
			}
		}
		'slave' : {
			concat::fragment {
				"streamingReplicationSlave" :
					target => "${datadir}/postgresql.conf",
					content =>
					inline_template("<% streamingReplicationSlave.sort_by {|key, value| key}.each do |key, value| %><%= key %> = <%= value %> \n<% end %>"),
					order => 02,
			}
			concat {
				"${datadir}/recovery.conf" :
					owner => "${install_owner}",
					group => "${install_owner}",
					mode => "0770",
			}
			Xebia_common::Features::Export_service_db <<| tag == "SpostgresqlRmasterU${universe}C${customer}A${application}" |>>
		}
	}
}