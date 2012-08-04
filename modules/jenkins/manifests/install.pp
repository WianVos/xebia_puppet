class jenkins::install inherits jenkins {
	# case the different installation methods
	# so far we only have one, but we can add the as we go 
	case $opendj::install {
		package : {
			
			package {
				'jenkins' :
					ensure => $jenkins::manage_package,
					name => $jenkins::install_package,
			}
		}
		default : {
			notify {
				"no default installation method for available for jenkins" :
			}
		}
	}
}