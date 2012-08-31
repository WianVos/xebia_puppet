class opendj::ldif_params(
	$universe 	= params_lookup('universe', 'global'),
	$basednsuffix = params_lookup('basednsuffix', 'global')
){
	$entitys = {"ou=applications,dc${universe},dc=${basednsuffix}" => {ensure => "present"},
				"ou=groups,dc${universe},dc=${basednsuffix}" => {ensure => "present"},
				"ou=users,dc${universe},dc=${basednsuffix}" => {ensure => "present"},
				"ou=test,ou=applications,dc${universe},dc=${basednsuffix}" => {ensure => "present"}
				}
}