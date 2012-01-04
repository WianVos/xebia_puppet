define common::source(
        $source_url,
        $target,
	$type="zip"
	)
	{
	
	case $type {
		zip : { common::archive::zip{"$name":
						source_url => $source_url,
						target => $target,
					}
			}
		targz : { common::archive::targz{"$name":
						source_url => $source_url,
						target => $target,
					}
			}
		
		regfile : { common::archive::regfile{"$name":
						source_url => $source_url,
						target => $target,
					}
			}
		default : { notice "$type is an unsupported archive" }	
		}
}
