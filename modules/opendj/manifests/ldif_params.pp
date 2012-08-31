class opendj::ldif_params(
	$universe 	= params_lookup('universe', 'global'),
	$basednsuffix = params_lookup('basednsuffix', 'global')
){
	$entitys = {'test1' => {dn => "ou=applications,dc${universe},dc=${basednsuffix}",ensure => "present"},
				'test2' => {dn => "ou=groups,dc${universe},dc=${basednsuffix}" ,ensure => "present"},
				'test3' => {dn => "ou=users,dc${universe},dc=${basednsuffix}", ensure => "present"}
				}
}