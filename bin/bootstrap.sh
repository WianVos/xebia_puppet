#!/bin/sh
set -x

#include conf file
. ../etc/bootstrap.conf

#get the node type
if [ $1 == "" ]; then node_group="default" ; else node_group=$1 ; fi

puppet node_aws bootstrap\
 --mode agent\
 --group $aws_sec_group\
 --image $aws_ami\
 --type $aws_ami_type\
 --region $aws_region\
 --pe-version=$pe_version\
 --login $image_login\
 --keyfile $image_keyfile\
 --keyname $image_keyname\
 --node-group $node_group\
 --enc-server $dashboard_server\
 --enc-ssl \
 --enc-auth-user $dashboard_auth_user\
 --enc-auth-passwd $dashboard_auth_passwd\
 --enc-port 443\
 --installer-answers $installer_answers\
 --installer-payload $installer_payload\
 --install-script $install_script
