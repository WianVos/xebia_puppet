/*
common:user
Group creation and checking is nog really in here .. 
i have to fix this later on .. (bummer)

*/
define common::user (
	$username="$name",
	$userid="",
	$gid="nogroup"
	)	
	{
	if !defined(Group[$gid]) {
       	 group {"$gid":
                ensure => present,
                }
        }

	user {"$username":
		ensure => present,
		gid => $gid,
		managehome => true,
		uid => $userid ? {
			"" => undef,
			default => $userid,
			}
		}

}
