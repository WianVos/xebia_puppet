#! /bin/bash

# parse commandline options
while getopts n:u:c:a:C:S:s:r: o
do case "$o" in
        u)universe=$OPTARG;;
        c)customer=$OPTARG;;
        a)application=$OPTARG;;
        S)service_size_parameter=$OPTARG;;
        s)worker_size_parameter=$OPTARG;;
        r)worker_role_parameter=$OPTARG;;
        ?)echo "Useage: -S <services_size> " 
                echo "  -u <universe name> " 
                echo "  -c <customer> "
                echo "  -a <application> "
                echo "  -s <worker size small/medium/large> "
                exit 0
esac
done

/opt/xebia_puppet/bin/xebia_bootstrap.sh -n deployit_host -u xebia & 
/opt/xebia_puppet/bin/xebia_bootstrap.sh -n postgresql_host -u xebia -c lg -R standalone &
sleep 120 
/opt/xebia_puppet/bin/xebia_bootstrap.sh -n jetty_host -u xebia -c lg -a test -R single &
/opt/xebia_puppet/bin/xebia_bootstrap.sh -n jetty_host -u xebia -c lg -a ontw -R single 
/opt/xebia_puppet/bin/xebia_bootstrap.sh -n jetty_host -u xebia -c lg -a acpt -R single 

su - peadmin -c 'mco puppetd runonce' 
