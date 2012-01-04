/*
targz  archive module
Download and unzip a zip archive

Parameters
$name=<archive filename>
$source_url=<file>
$target=<pathname>



*/
define common::archive::targz (
	$source_url,
	$target,
  	$regdir="/var/tmp",
	$timeout='360'
	){

  require common::packages
 
  if !defined(File[$target]) {
  	file {"$target":
		ensure => directory,
		}
	}

  exec {"$name download and unpack":
    command => "/usr/bin/curl ${source_url} | tar -xzf - -C ${target} && touch ${regdir}/${name}",
    creates => "$regdir/$name",
    require => [Package["curl"],File["${target}"]],
    path => ["/bin","/usr/bin", "/usr/sbin"],
    timeout => "$timeout",
    logoutput => "true",
		}

  
}
