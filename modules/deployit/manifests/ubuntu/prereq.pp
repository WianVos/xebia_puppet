class deployit::ubuntu::prereq inherits deployit::prereq{
  
  #needed packages
  Package{ensure => 'present'}
  package { 'openjdk-6-jdk':}
  package { 'unzip':}

 
}