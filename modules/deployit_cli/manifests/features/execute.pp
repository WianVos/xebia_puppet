#
# Resource: deployit::exec
#
# This resource executes a Deployit CLI script
#
# Parameters:
#
# Actions:
#
# Sample Usage:
#
# deployit::exec { 'run-my-cli-script':
#   username => 'admin',
#   password => 'admin',
#   source => '/tmp/cli.py',
#   creates => '/tmp/marker-file',
# }

define deployit_cli::features::execute(
	$source,
	$params = "",
	$homedir = "${deployit_cli::params::homedir}/cli"
) {

	if ! defined(Class["deployit_cli"]){
		class{"deployit_cli":} 
	}
	
	
	
	$username = "${deployit_user}"
	$password = "${deployit_password}"
	$host = "${deployit_host}"
	$port = "${deployit_port}"
	notice ("${deployit_user}")
	
	exec { "execute ${source} with params ${params}":
			cwd => "${homedir}",
			command => "${homedir}/bin/cli.sh -host ${host} -port ${port} -username ${username} -password ${password} -f ${source} -- ${params}",
			require => Class["deployit_cli"]
			}

#	if ("${username}" == "" ) or ("${password}" == "" ) or ("${host}" == "" ) or ("${port}" == "") {
#		notice "unable to run deployit command"
#	}
#	else {
#		exec { "execute ${source} with params ${params}":
#			cwd => "${homedir}",
#			command => "${homedir}/bin/cli.sh -host ${host} -port ${port} -username ${username} -password ${password} -f ${source} -- ${params}",
#			}
#	}
}
