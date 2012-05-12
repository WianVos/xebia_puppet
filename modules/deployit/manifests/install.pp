class deployit::install{
	
exec {"unzip deployit":
			command => "/usr/bin/unzip ",
			cwd => "${deployit::params::deployit_install_dir}"
			
	}
	
	
	
}