#! /bin/bash
debug="set -x"
$debug

#initialize variables
nodegroup="xx"
universe="xx"
customer="xx"
application="xx"
configfile="xx"
tmpfile=`tempfile`
hiera_data_dir="/var/xebia_puppet/hieradata/"


# parse commandline options
while getopts n:u:c:a:C: o
do case "$o" in
	n)node_group=$OPTARG;;
	u)universe=$OPTARG;;
	c)customer=$OPTARG;;
	a)application=$OPTARG;;
	C)configfile=$OPTARG;;
	?)echo "Useage: -n <nodegroup> " 
		echo "	-u <universe name> " 
		echo "	-c <customer> "
		echo "	-a <application> "
		echo "	-C <configfile> "
		exit 0 
esac
done

#check and correct input
if [ $node_group == "xx" ] ; then node_group="default" ; fi
if [ $universe == "xx" ] ; then universe="default" ; fi
if [ $customer == "xx" ] ; then customer="xebiaPuppet" ; fi
if [ $application == "xx" ] ; then customer="xebiaCustomer" ; fi
if [ $configfile == "xx" ] ; then configfile="../etc/bootstrap.conf" ; fi

#read in the configfile
. $configfile


# create the node
puppet node_aws create --group $aws_sec_group --image $aws_ami --type $aws_ami_type --region $aws_region --keyname $image_keyname 1>$tmpfile

# get het hostname
host=`tail -1 $tmpfile`

#setup the hiera classification for the host
if [ -f ../etc/nodeTypes/${node_group}.yaml ] 
	then 
	cp ../etc/nodeTypes/${node_group}.yaml /tmp/${node_group}.yaml
        cat /tmp/${node_group}.yaml | sed -e 's|<application>|'$application'|g' |  sed -e 's|<customer>|'$customer'|g' |  sed -e 's|<universe>|'$universe'|g'  >> ${hiera_data_dir}/hosts/${host}.yaml
else
	echo "unable to further classify ${host}"
fi 
 

puppet node classify --enc-server $dashboard_server  --enc-ssl --enc-auth-user $dashboard_auth_user --enc-auth-passwd $dashboard_auth_passwd --enc-port 443 --node-group $node_group ${host} 1>$tmpfile 2>&1

puppet node install --mode agent --pe-version=$pe_version --login $image_login --keyfile $image_keyfile --installer-answers $installer_answers --installer-payload $installer_payload --install-script $install_script ${host} 1>$tmpfile 2>&1
 


