#!/bin/bash
export RACK_ENV=production 
export RAILS_ENV=production
class_name=`pwd |nawk -F "/" '{print $(NF-1)}'`

/opt/puppet/bin/rake -f /opt/puppet/share/puppet-dashboard/Rakefile nodeclass:add name="${class_name}" 
/opt/puppet/bin/rake -f /opt/puppet/share/puppet-dashboard/Rakefile nodegroup:add name="${class_name}" classes="${class_name}","default" 
