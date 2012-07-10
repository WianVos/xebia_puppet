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

define deployit::features::execute(
	$source,
	$params = "",
	$homedir = "${deployit::params::homedir}/cli",
	$confdir = "/etc/xebia_puppet/config",
	$scriptdir = "${deployit::params::scriptdir}/deployit",
	$markerdir = "${deployit::params::markerdir}"
	
) {

	$markerfile = "${markerdir}/execute_deployit.txt"
	
	if ! defined(Class["deployit"]){
		class{"deployit":} 
	}

	if ! defined(File["run_cli.sh wrapper"]){
		file{"run_cli.sh wrapper":
			path => "${scriptdir}/run_cli.sh",
			content => template("deployit/run_cli.sh.erb"),
			owner	=> root,
			group	=> root,
			mode	=> "700",
		}
	}	
	
	exec { "execute ${source} with params ${params}":
			cwd => "${homedir}",
			command => "bash -c \'${scriptdir}/run_cli.sh -f ${source} -- ${params}\'; if [ $? -eq 0 ] ; then /bin/echo ${name} > ${markerfile} ; fi ",
			require => [File["run_cli.sh wrapper"]],
			unless => "/bin/grep ${name} ${markerfile}",
			logoutput => true,
			path => ["/usr/bin","/bin","/sbin","/usr/sbin"]
			}
}
