# Class: tomcat
#
# This module manages tomcat
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class tomcat {

	include tomcat::params
	
	case $operatingsystem {
                Ubuntu  : { include tomcat::ubuntu}
                default : { notice "unsupported operatingsystem ${operatingsystem}" }
                }
}
