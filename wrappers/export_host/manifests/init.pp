class export_host {
	
	class { "export_test::export":
			otap => 'accept',  
                        customer => 'xebia' }

}
