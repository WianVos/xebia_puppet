class deployit::ubuntu(){
	
	class {"deployit::ubuntu::prereq":}
	class {"deployit::ubuntu::install":
		require => Class["deployit::ubuntu::prereq"]
	}
}