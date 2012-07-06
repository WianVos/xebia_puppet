#!/bin/bash
export RACK_ENV=production 
export RAILS_ENV=production

for i in ` /opt/puppet/bin/rake -f /opt/puppet/share/puppet-dashboard/Rakefile  node:list |grep amazon `
	do
	puppet node clean $i
	 /opt/puppet/bin/rake -f /opt/puppet/share/puppet-dashboard/Rakefile  node:del  name=$i
	echo $i cleaned
	done
