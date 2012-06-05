class openam {
	include openam::params 
	
	case $::operatingsystem {
		Ubuntu : {
			include openam::ubuntu
		}
		default : {
			notice "unsupported operatingsystem ${::operatingsystem}"
		}
	}
}
	
