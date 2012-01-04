# Class: opendj
#
# This module manages opendj
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
class opendj::base {

	case $operatingsystem {
                Ubuntu  : { include opendj::ubuntu}
                default : { notice "unsupported operatingsystem ${operatingsystem}" }
                }

}
