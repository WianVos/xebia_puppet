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
	$username = 'undefined',
	$password = 'undefined',
	$source,
	$params = "",
	$host = "undefined",
	$port = "undefined"
) {

	include deployit

	$connectHost = $host ? {
		"undefined" => $::deployit_host,
		default => $host,
	}

	$connectPort = $port ? {
		"undefined" => $deployit::port,
		default => $port,
	}

	$connectUser = $username ? {
		"undefined" => $deployit::username,
		default => $username,
	}

	$connectPassword = $password ? {
		"undefined" => $deployit::password,
		default => $password,
	}

	exec { "execute ${source} with params ${params}":
		cwd => $deployit::cliHome,
		command => "${deployit::cliHome}/bin/cli.sh -host ${connectHost} -port ${connectPort} -username ${connectUser} -password ${connectPassword} -f ${source} -- ${params}",
	}

}
