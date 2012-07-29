define git::user (
	$ensure 	= "${git::manage_user}",
	$homedir 	= "/home/$name",
	$key		= ""
	) {
		
	if !defined(Group["${name}"]) {
		group {
			"${name}" :
				ensure => "${ensure}"
		}
	}
	if !defined(User["${name}"]) {
		user {
			"${name}" :
				gid => "${name}",
				ensure => "${ensure}",
				home => "${homedir}",
				managehome => true,
				require => User["${name}"],
				
		}
	}
	if !defined(Ssh_authorized_key["${name} key"]){
	ssh_authorized_key {
			"${name} key" :
				ensure => "${ensure}",
				key => "${key}",
				user => "${name}",
				require => User["${name}"],
				type => rsa
		}
	}
}