define common::source(
        $source_url,
        $target,
		$type	=	"zip",
		$owner	=	"root",
		$group 	=	"system", 
		$mode	=	"700",
		$regdir	=	"/etc/xebia_puppet_reg"
	)
{
	if !defined(File["${regdir}"]) {
		file {"${regdir}":
				ensure 	=> directory,
				owner 	=> "root",
		}
	}
	
	
	case $type {
		zip : { common::archive::zip{"$name":
						source_url 	=> $source_url,
						target 		=> $target,
						owner 		=> "${owner}",
						regdir		=> "${regdir}"
					}
				}
		targz : { common::archive::targz{"$name":
						source_url 	=> $source_url,
						target 		=> $target,
						owner 		=> "${owner}",
						regdir		=> "${regdir}"
						
					}
				}
		
		regfile : { common::archive::regfile{"$name":
						source_url 	=> $source_url,
						target 		=> $target,
						owner 		=> "${owner}",
						group		=> "${group}",
						mode		=> "${mode}",
						regdir		=> "${regdir}"						
					}
				}
		default : { notice "$type is an unsupported archive" }	
		}
}
