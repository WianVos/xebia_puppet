define deployit::types::postgresql_ssh (
	$db_name        ,
	$environments 	= "${::environment}",
	$remotefqdn  	= "",
	$customer       = undef,
	$application	= undef,
	$postgresql_home = "/opt/postgresql",
	$db_username	= "",
	$db_password	= "",
	$remotehost		= "",
	$appstage		= undef
	) {
	if ! defined(Deployit::Features::Ci["${customer} dir"]){
		deployit::features::ci {
							"${customer} dir" :
								ciId => "Environments/${customer}",
								ciType => 'core.Directory',
								ciValues => {name => "${customer}"},
								ensure => present
						}
	}
	
	if ! defined(Deployit::Features::Ci["${customer}/${application} dir"]){
		deployit::features::ci {
							"${customer}/${application} dir" :
								ciId => "Environments/${customer}/${application}",
								ciType => 'core.Directory',
								ciValues => {name => "${application}"},
								ensure => present,
								require => Deployit::Features::Ci["${customer} dir"]
						}		
		
	}
	
	if ! defined(Deployit::Features::Ci["${customer}/${application}/${appstage} dir"]){
		deployit::features::ci{ "${customer}/${application}/${appstage} env":
 				 ciId => "${customer}/${application}/${appstage}",
  				 ciType => 'core.Directory',
  				 ciValues => { name => "${appstage}"},
  				 ensure => present,
  				 require => Deployit::Features::Ci["${customer}/${application} dir"]
		}
	}
	
	if ! defined(Deployit::Features::Ci["${customer}/${application}/${appstage}/${application}-${appstage} env"]){
		deployit::features::ci{ "${customer}/${application}/${appstage}/${application}-${appstage} env":
 				 ciId => "${customer}/${application}/${appstage}/${application}-${appstage}",
  				 ciType => 'udm.Environment',
  				 ciValues => { name => "${application}-${appstage}"  },
  				 ensure => present,
  				 require => Deployit::Features::Ci["${customer}/${application} dir","${application}-${appstage} env dir","${customer} dir"]
		}
	}
	
	if ! defined(Deployit::Features::Ci["${remotehost}-ssh-host"]){
	deployit::features::ci{ "${remotehost}-ssh-host":
 				 ciId => "Infrastructure/${remotehost}",
  				 ciType => 'overthere.SshHost',
  				 ciValues => { os => UNIX, connectionType => SUDO, username => 'deployit', password => 'deployit',
                 		sudoUsername => 'root', address => "${remotefqdn}", privateKeyFile => "/opt/deployit/keys/jetty_id_rsa" },
                 		ciEnvironments => "${customer}/${application}/${appstage}/${application}-${appstage}",
  				 ensure => present,
  				 require => Deployit::Features::Ci["${customer}/${application}/${appstage}/${application}-${appstage} env"]
  				 
		}
	}
	
		if !defined(Deployit::Features::Ci["postgresql_database_${db_name}"]) {
			deployit::features::ci {
				"postgresql_database_${db_name} " :
					ciId => "Infrastructure/${remotehost}/${db_name}",
					ciType => 'sql.PostgreSqlClient',
					ciValues => {postgresqlHome => "$postgresql_home", databaseName =>
					"${db_name}", username => "${db_username}", password => "${db_password}"},
					ciEnvironments => "${customer}/${application}/${appstage}/${application}-${appstage}",
					require => Deployit::Features::Ci["${remotehost}-ssh-host"],
					ensure => present,
			}
		}
	}
	

