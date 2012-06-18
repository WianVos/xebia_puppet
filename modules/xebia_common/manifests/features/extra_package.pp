define xebia_common::features::extra_package (
		$package_name   = $name,
		$ensure  		= "latest"
){

if !defined(Package["${package_name}"]){
		package{"${package_name}":
			ensure 	=> "${ensure}"
			}
	}
}