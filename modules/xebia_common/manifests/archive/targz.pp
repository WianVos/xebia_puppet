/*
targz  archive module
Download and unzip a zip archive

Parameters
$name=<archive filename>
$source_url=<file>
$target=<pathname>



*/
define xebia_common::archive::targz (
	$source_url,
	$target,
  	$regdir="/var/tmp",
	$timeout='360',
	$owner = 'root',
	$group = 'root',
	$mode = '700'
	){

  require xebia_common::packages
 
  
  file {"${name}_${target}":
     path	=> "${target}",	
     ensure 	=> directory,
     before	=> Exec["$name download and unpack"],
     }

  exec {"$name download and unpack":
    command 	=> "/usr/bin/curl ${source_url} | tar -xzf - -C ${target} && chown -R ${owner}:${group} ${target} && chmod -R ${mode} ${target} && touch ${regdir}/${name}",
    creates 	=> "$regdir/$name",
    path 	=> ["/bin","/usr/bin", "/usr/sbin"],
    timeout 	=> "$timeout",
    logoutput 	=> true,
	}

  
}
