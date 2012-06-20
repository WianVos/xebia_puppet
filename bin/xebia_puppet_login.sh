#!/bin/bash

#uncomment the following line for debug information
#debug="set -x"
$debug

#source the environment configuration
. ../etc/bootstrap.conf

#create a tmpfile to hold the host choices
tmpfile=`tempfile`

#fill the tmpfile with available hosts in the region 
for x in `puppet node_aws list --verbose --region=eu-west-1 |grep dns_name|cut -d :  -f 2 ` ; do 

	if [ x != "" ] ; then 
		echo "$x" >> ${tmpfile}
	fi
done

# run a continous loop and display the choices to the user. 
# he will be given a choice and is able to login
while [[ 1 ]]
do
    cat -n "$tmpfile"
    read -p "Please make a selection, select q to quit: " choice
    case $choice in
            # Check for digits
    [0-9] )   aws_host=$(sed -n "$choice"p "$tmpfile")
	      if [ $aws_host != "" ] then
              ssh -i ${image_keyfile} ${image_login}@$aws_host 
	      else 
	      echo "Invalid choice"
	      fi 
	      ;;
     q|Q)
         break
           ;;
      *)
           echo "Invalid choice"
           ;;
    esac
done

#cleanup the tmpfile
rm -rf $tmpfile

