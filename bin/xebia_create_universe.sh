#! /bin/bash

universe="xx"
customer="xx"
application="xx"
appstage="xx"
configfile="xx"
tmpfile=`tempfile`
service_role="xx"
hiera_data_dir="/var/xebia_puppet/hieradata/"
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

#select instance type
case "$size_parameter" in
                "s" | "S" | "small"  ) instance_size="m1.small";;
                "m" | "M" | "medium" ) instance_size="m1.medium";;
                "l" | "L" | "large"  ) instance_size="m1.large";;
                *              ) instance_size="m1.small";;
                esac


#check and correct input
if [ $universe == "xx" ] ; then universe="default" ; fi
if [ $customer == "xx" ] ; then customer="xebiaCustomer" ; fi
if [ $application == "xx" ] ; then application="xebiaApplication" ; fi

/opt/xebia_puppet/bin/xebia_bootstrap.sh -n deployit_host -u ${universe}   
/opt/xebia_puppet/bin/xebia_bootstrap.sh -n postgresql_host -u ${universe}  -c ${customer} -a ${application} -R standalone 
sleep 400 
/opt/xebia_puppet/bin/xebia_bootstrap.sh -n jetty_host -u ${universe}  -c ${customer} -a ${application} -s ontw -R single  
su - peadmin -c 'mco puppetd runonce'
/opt/xebia_puppet/bin/xebia_bootstrap.sh -n jetty_host -u ${universe}  -c ${customer} -a ${application} -s tst -R single 
su - peadmin -c 'mco puppetd runonce'
