class git::params{
	
	
	$version 					= 	'3.7.3'
	$basedir 					= 	'/opt/git_base'
	$homedir 					= 	'/opt/git'
	$install_package			=	'git-core'
	$install_filesource			= 	'puppet:///modules/git'
	$install_owner				= 	'git'
	$install_group				= 	'git'
	$plugin_install				= 	true
	$key_install				= 	true

	#universe settings
	$universe					= 	'general'

	#module management settings
	$packages 					= 	['openjdk-6-jdk', 'unzip']
	$tmpdir						= 	'/var/tmp/git'
	$absent 					=	false
	$disabled 					= 	false
	$ensure						= 	'running'
	$import_facts				= 	true
	$import_config				= 	true
	$baseconfdir				=	'/etc/xebia_puppet'
	$confdir					= 	'/etc/xebia_puppet/config'
	$scriptdir					= 	'/etc/xebia_puppet/script'
	$markerdir					= 	'/etc/xebia_puppet/marker'
	$export_facts				= 	true
	$export_config				= 	true
	$install					= 	'package'
	
	# 
	$repo_basedir				= 	'/var/git_repo'
	$repos						= {test_repo1 => { key => "AAAAB3NzaC1yc2EAAAABIwAAAQEA0g6DUrMHsEFYb58cam+WaUoqDi0qhHc6sVcVR/Rb9XGWo9faTCfWukS7iYqfNKhsm5+lLAmBIe7ycyfWHcxvWL3vOAZBNlceImPl96Ow2op2Kej9wMYD1jFcgGmekOzzW+ZyOWStXUyzXS48cijG1C/m7+zizezL8i10rPjIKpiQVOm8io8iPOXI69YKej1x9U8Lz/JKV353n7KoaAycu5q2YN2rGyCs7jnNZgoP7agrQZs2vsCHbHs5UZVQVYiKIKKo6TK7oZQHZom8dAi/01GZRBS/BKFr0VnyUA79xLrRwcJ2Wgtlc5K76ItKOxqpJ7Ji2HxSRyFkESkXnbXuTQ=="}}
												  
	

}