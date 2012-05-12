class deployit::ubuntu::prereq inherits deployit::prereq{
  
  #needed packages
  Package{ensure => 'present'}
  
  package { 'openjdk-6-jdk':}
  package { 'unzip':}
  
  file {"$deployit::params::deployit_tmpdir": ensure => directory, mode = 700 , owner => root, group => root }

  class {'nexus':
    url => "http://dexter.xebialabs.com/nexus",
    username => "deployment",
    password => "_#$(%RJf-W}",
  }

  nexus::artifact {'deployit-server':
    gav => "com.xebialabs.deployit:deployit:${deployit::params::completeVersion}",
    classifier => 'server',
    packaging => 'zip',
    repository => "releases",
    output => "/download-cache/deployit-${deployit::params::completeVersion}-server.zip",
    ensure => present,
  }
}