class import_host {
	
	class { "export_test::import":
			otap => 'accept',
			customer => 'xebialabs'  }

}
