#!/bin/sh

puppet node_aws bootstrap\
 --mode agent\
 --group wian\
 -i ami-ad36fbc4\
 --type m1.large\
 --pe-version=2.0\
 --login ubuntu\
 --keyfile /root/wianpe12.pem\
 --keyname wianpe12\
 --node-group tomcat\
 --enc-server ip-10-111-10-44.ec2.internal\
 --enc-ssl \
 --enc-auth-user xadmin\
 --enc-auth-passwd xitaxita01\
 --enc-port 443\
 --installer-answers /root/client_answer.txt\
 --installer-payload /root/puppet-enterprise-2.0-all.tar.gz\
 --install-script puppet-enterprise\
