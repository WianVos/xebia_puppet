define jetty::auto::postgresql(
	$instance_name,
	$application 	= "",
	$customer		= "",
	$universe		= "",
	$stage			= ""
){
	@@postgresql::export_create_db {
 		"${instance_name}" :
 			application => "${application}",
 			customer => "${customer}",
 			universe => "${universe}",
 			stage	=> "${stage}"
 	}
 	
}