define deployit::types::jetty_ssh ($remotehost, 
	$homedir	,
	$instance_name ,
	$environments 	= "${::environment}",
	$remotefqdn 	= "",
	$customer		= "default",
	$application	= "default",
	$remotehost	= "",
	$appstage			= "test"
	) {
		
	if !defined(Deployit::Features::Ci["${customer} dir"]) {
		deployit::features::ci {
			"${customer} dir" :
				ciId => "Environments/${customer}",
				ciType => 'core.Directory',
				ciValues => {name => "${customer}"},
				ensure => present
		}
	}
	if !defined(Deployit::Features::Ci["${customer}/${application} dir"]) {
		deployit::features::ci {
			"${customer}/${application} dir" :
				ciId => "Environments/${customer}/${application}",
				ciType => 'core.Directory',
				ciValues => {name => "${application}"},
				ensure => present,
				require => Deployit::Features::Ci["${customer} dir"]
		}
	}
	if !defined(Deployit::Features::Ci["${customer}/${application}/${appstage} dir"])
	{
		deployit::features::ci {
			"${customer}/${application}/${appstage} dir" :
				ciId => "Environments/${customer}/${application}/${appstage}",
				ciType => 'core.Directory',
				ciValues => {name => "${appstage}"},
				ensure => present,
				require => Deployit::Features::Ci["${customer}/${application} dir"]
		}
	}
	if !defined(Deployit::Features::Ci["${customer}/${application}/${appstage}/${application}-${appstage} env"])
	{
		deployit::features::ci {
			"${customer}/${application}/${appstage}/${application}-${appstage} env" :
				ciId =>
				"Environments/${customer}/${application}/${appstage}/${application}-${appstage}",
				ciType => 'udm.Environment',
				ciValues => {name => "${application}-${appstage}"},
				ensure => present,
				require => Deployit::Features::Ci["${customer}/${application} dir",
				"${customer}/${application}/${appstage} dir", "${customer} dir"]
		}
	}
	if !defined(Deployit::Features::Ci["${remotehost} ssh-host"]) {
		deployit::features::ci {
			"${remotehost} ssh-host" :
				ciId => "Infrastructure/${remotehost}",
				ciType => 'overthere.SshHost',
				ciValues => {os => UNIX, connectionType => SUDO, username => 'deployit',
				password => 'deployit', sudoUsername => 'root', address => "${remotefqdn}",
				privateKeyFile => "/opt/deployit/keys/jetty_id_rsa"},
				ciEnvironments =>
				"${customer}/${application}/${appstage}/${application}-${appstage}",
				ensure => present,
				require =>
				Deployit::Features::Ci["${customer}/${application}/${appstage}/${application}-${appstage} env"]
		}
	}
	deployit::features::ci {
		"jetty_server_${remotehost}_${instance_name} " :
			ciId => "Infrastructure/${remotehost}/${instance_name}",
			ciType => 'jetty.Server',
			ciValues => {home => "$homedir", startScript => "${homedir}/start.sh",
			stopScript => "${homedir}/stop.sh"},
			ciEnvironments =>
			"Environments/${customer}/${application}/${appstage}/${application}-${appstage}",
			require => Deployit::Features::Ci["${remotehost} ssh-host",
			"${customer}/${application}/${appstage}/${application}-${appstage} env"],
			ensure => present,
	}
	}
