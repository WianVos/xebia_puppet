define opendj::ldiff(
	$ensure 	= "present",
	$ldiffFile,
	$rootuser		= "${opendj::rootuser}",
	$rootpassword	= "${opendj::rootpassword}",
	$mgtport		= "${opendj::mgtport}",
	$hostname		= "localhost",
	$includeBranch	= "dc=${opendj::universe},${opendj::basednsuffix}"
		
){
	#import-ldif
 	#--port 4444
 	#--hostname opendj.example.com
 	#--bindDN "cn=Directory Manager"
 	#--bindPassword password
  	#--includeBranch dc=example,dc=org
 	#--backendID userRoot
 	#--ldifFile /path/to/generated.ldif
 	#--trustAll
}