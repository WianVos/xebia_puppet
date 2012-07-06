#!/bin/bash
export RACK_ENV=production 
export RAILS_ENV=production

for i in ` /opt/puppet/bin/rake -f /opt/puppet/share/puppet-dashboard/Rakefile  node:list |grep amazon |cut -d "-" -f 1-7`
	do
	echo $i
	done
