# Class: common
#
# This module manages common
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
class common::packages {

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
