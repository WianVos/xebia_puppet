define git::repo(
	$repo_owner = "${name}",
	$repo_base = "/var/repo",
	$key	
){
	# set repo dir
	$repo_dir	= "${repo_base}/${name}"
	
	#create the user and group
	git::user {"${name}":
			key => "${key}"
	}
	#create the repo base dir 
	
	#create the repo_dir
	
	#git: initialize te repo
	
	
}