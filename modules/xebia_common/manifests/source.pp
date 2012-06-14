define xebia_common::source(
        $source_url,
        $target,
		$type	=	"zip",
		$owner	=	"root",
		$group 	=	"root", 
		$mode	=	"700",
		$regdir	=	"/etc/xebia_puppet/regdir"
	)
{
	
	case $type {
		zip : { xebia_common::archive::zip{"$name":
						source_url 	=> $source_url,
						target 		=> $target,
						owner 		=> "${owner}",
						group		=> "${group}",
						mode		=> "${mode}",
						regdir		=> "${regdir}"
					}
				}
		targz : { xebia_common::archive::targz{"$name":
						source_url 	=> $source_url,
						target 		=> $target,
						owner 		=> "${owner}",
						group		=> "${group}",
						mode		=> "${mode}",
						regdir		=> "${regdir}"
						
					}
				}
		
		regfile : { xebia_common::archive::regfile{"$name":
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
