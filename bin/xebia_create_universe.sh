#! /bin/bash
debug="set -x"
$debug

#initialize variables
universe="xx"
customer="xx"
application="xx"
tmpfile=`tempfile`
size='xx'
appnames='xx'


# parse commandline options
while getopts u:c:A:s o
do case "$o" in
	u)universe=$OPTARG;;
	c)customer=$OPTARG;;
	A)appnames=$OPTARG;;
	s)size=$OPTARG;;
	?)echo "			"
		echo "	-u <universe name> " 
		echo "	-c <customer> "
		echo "	-a <application> "
		echo "  -A <app-names> comma separate list" 
		echo "  -s default size application containers" 
		exit 0 
esac
done

		
	
#check and correct input
if [ $appnames == "xx" ] ; then appnames="default" ; fi
if [ $universe == "xx" ] ; then universe="default" ; fi
if [ $customer == "xx" ] ; then customer="xebiaPuppet" ; fi
if [ $size == "xx" ] ; then size="s" ; fi

#install services




#install containers
