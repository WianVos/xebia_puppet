#!/bin/sh
puppet_url="https://pm.puppetlabs.com/puppet-enterprise/latest/puppet-enterprise-latest-all.tar.gz"
target_puppet_sourcedir="/opt/puppet_source" 
puppet_conf_file="/etc/puppetlabs/puppet/puppet.conf"
tmp_dir="/var/tmp"
xebia_puppet_base="/opt/xebia_puppet"

#mkdir -p $target_puppet_sourcedir
#/usr/bin/curl $puppet_url |tar -xzf - -C $target_puppet_sourcedir  

# find the puppet enterprise installer
#installer_command=`find /opt -name puppet-enterprise-installer`

#install puppet using the silent installfile in the ../etc dir
#$installer_command -a ../etc/xebia_puppet_install.conf 

#modify puppet.conf
#mv $puppet_conf_file $tmp_dir/puppet.conf
#cat $tmp_dir/puppet.conf | sed -e ' s|modulepath = /etc/puppetlabs/puppet/modules:/opt/puppet/share/puppet/modules|modulepath = /etc/puppetlabs/puppet/modules:/opt/puppet/share/puppet/modules:'$xebia_puppet_base'/modules:'$xebia_puppet_base'/wrappers|g' >> $puppet_conf_file

#setup fog
cp ../etc/fog.conf ~/.fog

