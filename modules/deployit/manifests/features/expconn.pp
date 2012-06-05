class deployit::features::expconn(
	$configdir = '/etc/xebia_puppet/etc'
	
){
	@@file{"${configdir}":
			content
	}
}