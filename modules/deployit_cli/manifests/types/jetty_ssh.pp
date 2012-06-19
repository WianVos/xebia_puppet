define deployit_cli::types::jetty_ssh ($hostname = "${::hostname}",
	$environments = "${::environment}",
	$fqdn = "${::fqdn}",
	$homedir = "/opt/jetty",
	$instanceName = "default_jetty"
	){
	
	
	
	if !defined(Deployit_cli::Types::Overthere_ssh["${hostname} jetty overthere_ssh"]){
		deployit_cli::types::overthere_ssh {
			"${hostname} jetty overthere_ssh" :
				hostname => "${::hostname}",
				environments => "${environments}",
				fqdn => "${fqdn}"
		}
	}
	
	deployit_cli::features::ci {
		"jetty_server_${hostname}_${instanceName} " :
			ciId => "Infrastructure/${hostname}/${instanceName}",
			ciType => 'jetty.Server',
			ciValues => {home => "$homedir", startScript => "${homedir}/start.sh",
			stopScript => "${homedir}/bin/stop.sh"},
			ciEnvironments => "${environments}",
			require =>
			Deployit_cli::Types::Overthere_ssh["${hostname} jetty overthere_ssh"],
			ensure => present,
	}
}