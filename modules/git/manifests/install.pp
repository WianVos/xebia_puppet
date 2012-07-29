class git::install inherits git {
	# case the different installation methods
	# so far we only have one, but we can add the as we go 
	case $git::install {
		package : {
			
			package {
				"${git::install_package}" :
					ensure => $git::manage_package,
					name => $git::install_package,
			}
		}
		default : {
			notify {
				"no default installation method for available for git" :
			}
		}
	}
}