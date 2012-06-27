define export_test::exported(
	$stage 	= "xx",
	$customer	= "xx"
){

	if (($stage == $export_test::import::stage) or ( $stage == "xx" )) 
		and 
	   (($customer == $export_test::import::customer) or ( $customer == "xx" ))
  		{
			file {"/tmp/${name}":
				content => "test",
				ensure => "present" 
				}
		}else{
	
	       		file {"/tmp/{$name}:
				ensure => abent
				}	
		}		

}
