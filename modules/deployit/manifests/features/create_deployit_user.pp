class deployit::create_deployit_user.pp(
	$user_name = params_lookup("install_user"),
	$group	= params_lookup("install_user"),
	$key	= params_lookup("install_user_key"),
	$ensure = true
){

 group {
	"${group}":
	}

 user { 
	"${user_name}:
		gid 		=> "${group}",
		managehome	=> true,		
	}
		 
 exec { "${user_name} sudo":
                command => "/bin/echo \'${user_name} ALL=(ALL) NOPASSWD:ALL\' >> /etc/sudoers ",
                unless => "/bin/grep ${user_name} /etc/sudoers",
                require => User["${user_name}"]
        }
 ssh_authorized_key {
                "$install_owner key":
                        ensure          => "${ensure}",
                        key             => "${key}",
                        user            => "${user_name}",
                        require         => User["${user_name}"],
                        type            => rsa
        }
}
