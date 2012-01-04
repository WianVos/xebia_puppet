class weblogic::params {
	
	$installpath = $::weblogic_installpath ? {
		''	=> "/opt/weblogic",
		default => "${::weblogic_installpath}"
		}
	
	$tmpdir = $::weblogic_tmpdir ? {
		'' 	=> "/opt/weblogictmp",
		default => "${::weblogic_tmpdir}"
		} 
	$jarfile = $::weblogic_jarfile ? {
		'' 	=> "wls1034_generic.jar",
		default => "${::weblogic_jarfile}"
		}
	$versionnumber = $::weblogic_versionnumber ? {
		''	=> "1034",
		default => "${::weblogic_versionnumber}"
		}
	$jvmpath = $::weblogic_jvmpath ? {
		''	=> "/opt/jrockit",
		default => "${::weblogic_jvmpath}"
		}
}
