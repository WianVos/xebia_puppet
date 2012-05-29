#!/bin/sh
puppet_url="https://pm.puppetlabs.com/puppet-enterprise/latest/puppet-enterprise-latest-all.tar.gz"
target_puppet_sourcedir="/opt/puppet_source" 

mkdir -p $target_puppet_sourcedir
/usr/bin/curl $puppet_url |tar -xzf - -C $target_puppet_sourcedir  
