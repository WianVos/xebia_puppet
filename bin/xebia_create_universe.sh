#! /bin/bash
/opt/xebia_puppet/bin/xebia_bootstrap.sh -n deployit_host -u xebia & 
sleep 60
/opt/xebia_puppet/bin/xebia_bootstrap.sh -n postgresql_host -u xebia -c lg -R standalone &
sleep 60 
/opt/xebia_puppet/bin/xebia_bootstrap.sh -n jetty_host -u xebia -c lg -a test -R single &
sleep 60
/opt/xebia_puppet/bin/xebia_bootstrap.sh -n jetty_host -u xebia -c lg -a ontw -R single 
sleep 30 
/opt/xebia_puppet/bin/xebia_bootstrap.sh -n jetty_host -u xebia -c lg -a acpt -R single 

su - peadmin -c 'mco puppetd runonce' 
