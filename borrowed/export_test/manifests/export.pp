class export_test::export(
        $otap    = "xx",
        $customer = "xx"
){

	@@exported{"${::hostname}":
			otap => $otap,
			customer => $customer
		}

}
