define export_test::exported(
	$otap 		= "xx",
	$customer	= "xx"
){

	if (("${otap}" == "${export_test::import::otap}") or ( $otap == "xx" )) 
		and 
	   (("${customer}" == "${export_test::import::customer}") or ( $customer == "xx" ))
  		{
			file {"/tmp/${name}":
				content => "${otap} ${customer}",
				ensure => "present" 
				}
		}else{
	
	       		file {"/tmp/${name}":
				ensure => "absent"
				}	
		}		

}
