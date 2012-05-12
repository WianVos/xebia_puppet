class deployit::prereq(){

File { ensure => ${deployit::ensure} ? { "present" => "directory", "absent" => "absent", default => "directory"}, mode => 700, owner => root, group => root }	

# set up the needed directory's
file {"$deployit::params::deployit_tmpdir": }
file {"$deployit::params::deployit_install_dir": }

# link the homedir to the installdir
file {"$deployit::params::deployit_home_dir":
	ensure => ${deployit::ensure} ? { "present" => "link", "absent" => "absent", default => "link"},
	target => "${deployit::params::deployit_install_dir}"
}
  

class {'nexus':
    url => "${deployit::params::nexus_url}",
    username => "${deployit::params::nexus_username}",
    password => "${deployit::params::nexus_password}",
  }

nexus::artifact {'deployit-server':
    gav => "com.xebialabs.deployit:deployit:${deployit::params::completeVersion}",
    classifier => 'server',
    packaging => 'zip',
    repository => "releases",
    output => "${deployit::params::deployit_tmpdir}/deployit-${deployit::params::completeVersion}-server.zip",
    ensure => "${deployit::ensure}",
  }
}