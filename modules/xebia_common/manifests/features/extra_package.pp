define xebia_common::features::extra_package (
		$ensure  		= "latest"
){

if !defined(Package["${name}"]){
		package{"${name}":
			ensure 	=> "${ensure}"
			}
	}
}