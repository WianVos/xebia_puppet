class deployit::ubuntu::prereq inherits deployit::prereq{
  
  #needed packages
  Package{ ensure => "${deployit::ensure}" }
  
  package { 'openjdk-6-jdk':}
  package { 'unzip':}
  
  
}