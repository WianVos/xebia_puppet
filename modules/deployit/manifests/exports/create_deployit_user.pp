class deployit::exports::create_deployit_user(
	$user_name = params_lookup("install_owner"),
	$group = params_lookup("install_owner"),
	$key = params_lookup("install_user_key"),
	$universe = params_lookup('univers', global),
	$timestamp	=	inline_template("<%= Time.now.strftime('%Y-%m-%dT%H:%M:%S%z') %>"),
	$maxage 	= 	"28800"
	) {
		$age =
		inline_template("<%= require 'time'; Time.now - Time.parse(timestamp) %>")
		
		if ("${age}" < "${maxage}") {
			$ensure_age = true
		}
		
		if ($universe == params_lookup("universe", global)) {
			$ensure_universe = true
		}
		
		if (($ensure_age == true) and ($ensure_universe == true)) {
			$ensure = true
		}
		else {
			$ensure = false
		}
		
		group {
			"${group}" :
				ensure => "${ensure}"
		}
		user {
			"${user_name}" :
				gid => "${group}",
				managehome => true,
				ensure => "${ensure}"
		}
		exec {
			"${user_name} sudo" :
				command =>
				"/bin/echo \'${user_name} ALL=(ALL) NOPASSWD:ALL\' >> /etc/sudoers ",
				unless => "/bin/grep ${user_name} /etc/sudoers",
				require => User["${user_name}"]
		}
		ssh_authorized_key {
			"${user_name} key" :
				ensure => "${ensure}",
				key => "${key}",
				user => "${user_name}",
				require => User["${user_name}"],
				type => rsa
		}
	}
	

