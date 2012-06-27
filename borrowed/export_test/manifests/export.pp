class export_test::export(
        $stage    = "xx",
        $customer       = "xx"
)inherits export_test::params{

	@@exported{"${::hostname}":
			stage => $stage,
			customer => $customer
		}

}
