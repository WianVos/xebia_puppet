class weblogic::params {
	$installpath = $::weblogic_installpath ? {
		''	=> "/opt/weblogic",
		default => "${::weblogic_installpath}"
		}
	$infradir = $::weblogic_infradir ? {
		''	=> "/etc/xebia_infra",
		default => "${::weblogic_infradir}"
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
	$data_dir = "/data"
	$domain_base_dir = "${data_dir}/domains"
	$application_base_dir = "${data_dir}/applications"
	$log_base_dir = "${data_dir}/logs"
	$password = "fifaifoefung666"
	
}	
