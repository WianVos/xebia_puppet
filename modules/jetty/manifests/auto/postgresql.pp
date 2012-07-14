define jetty::auto::postgresql(
	$instance_name,
	$application 	= "",
	$customer		= "",
	$universe		= "",
	$appstage			= ""
){
	@@postgresql::export_create_db {
 		"${instance_name}" :
 			application => "${application}",
 			customer => "${customer}",
 			universe => "${universe}",
 			appstage	=> "${appstage}"
 	}
 	
}