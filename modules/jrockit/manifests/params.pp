class jrockit::params {
	
	$installpath = $::jrockit_installpath ? {
		''	=> "/opt/jrockit",
		default => "${::jrockit_installpath}"
		}
	
	$tmpdir = $::jrockit_tmpdir ? {
		'' 	=> "/opt/puppettmp",
		default => "${::jrockit_tmpdir}"
		} 
	$binfile = $::jrockit_binfile ? {
		'' 	=> "jrockit-jdk1.6.0_29-R28.2.0-4.1.0-linux-x64.bin",
		default => "${::jrockit_binfile}"
		}

}
