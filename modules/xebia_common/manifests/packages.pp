# Class: xebia_common
#
# This module manages xebia_common
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
class xebia_common::packages {

 if !defined(Package['curl']) {
    package{'curl':
      ensure => present,
    }
  }

 if !defined(Package['unzip']) {
    package{'unzip':
      ensure => present,
    }
  }}
