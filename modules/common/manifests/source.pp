define common::source(
        $source_url,
        $target,
		$type	=	"zip",
		$owner	=	"root",
		$group 	=	"system", 
		$mode	=	"700"
	)
	{
	
	case $type {
		zip : { common::archive::zip{"$name":
						source_url 	=> $source_url,
						target 		=> $target,
						owner 		=> "${owner}"
					}
				}
		targz : { common::archive::targz{"$name":
						source_url 	=> $source_url,
						target 		=> $target,
						owner 		=> "${owner}"
					}
				}
		
		regfile : { common::archive::regfile{"$name":
						source_url 	=> $source_url,
						target 		=> $target,
						owner 		=> "${owner}",
						group		=> "${group}",
						mode		=> "${mode}"
					}
				}
		default : { notice "$type is an unsupported archive" }	
		}
}
