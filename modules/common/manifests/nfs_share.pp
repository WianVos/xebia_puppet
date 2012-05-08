define common::nfs_share(
	$path = "$name",
	$hosts = "",
	$options = "async,"
){
	
	package{"${name} nfs_server":
		name => $::operatingsystem ?{
				ubuntu => "nfs-kernel-server",
				default => "nfs-kernel-server"},
		ensure => present,
		}
	
	case $options {
		"": 		{ $options_string = ""	}
		default: 	{ $options_string = "-o ${options}"}
		} 
	
	
	exec{"export ${hosts}:${path}":
		command => "/usr/sbin/exportfs ${options_string} ${hosts}:${path} && touch /var/tmp/share_${path}",
		creates => "/var/tmp/share_${path}"
	}	

}