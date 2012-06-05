class openam::ubuntu::base {
	
	require openam::ubuntu::params
	
	include openam::ubuntu::prereq
	include openam::ubuntu::install
	include openam::ubuntu::configure
	include openam::ubuntu::service
	
	Class[openam::ubuntu::service] -> Class[openam::ubuntu::configure] -> Class[openam::ubuntu::install] -> Class[openam::ubuntu::prereq]

		
}