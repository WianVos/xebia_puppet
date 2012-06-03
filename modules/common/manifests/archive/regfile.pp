/*
targz  archive module
Download and unzip a zip archive

Parameters
$name=<archive filename>
$source_url=<file>
$target=<pathname>



*/
define common::archive::regfile (
	$source_url,
	$target,
  	$regdir		= "/var/tmp",
	$timeout	= '360',
	$owner		= 'root',
	$group		= 'root',
	$mode		= '700'
	){

  require common::packages
 
  if !defined(File[$target]) {
  	file {"$target":
		ensure => directory,
		}
	}

  exec {"$name download":
    		command 	=> "/usr/bin/curl ${source_url} -o ${target}/${name} && touch ${regdir}/${name}",
    		creates	 	=> "$regdir/$name",
    		require 	=> [Package["curl"],File["${target}"]],
    		path 		=> ["/bin","/usr/bin", "/usr/sbin"],
    		timeout 	=> "$timeout",
    		logoutput 	=> true,
	}
	
  file {"${target}/${name}":
  			ensure 		=> present,
  			owner		=> "${owner}",
  			group		=> "${group}", 
  			mode		=> "${mode}",
  			require		=> Exec["$name download"]
  }

  
}
