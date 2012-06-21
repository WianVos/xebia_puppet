#!/bin/sh
set -x
puppet_url="https://pm.puppetlabs.com/puppet-enterprise/latest/puppet-enterprise-latest-all.tar.gz"
puppet_lucid_url="https://pm.puppetlabs.com/puppet-enterprise/latest/puppet-enterprise-latest-ubuntu-10.04-amd64.tar.gz"
target_puppet_sourcedir="/opt/puppet_source" 
puppet_conf_file="/etc/puppetlabs/puppet/puppet.conf"
puppet_hiera_conf_file="/etc/puppetlabs/puppet/hiera.yaml"
tmp_dir="/var/tmp"
xebia_puppet_base="/opt/xebia_puppet"
hiera_data_dir="/var/xebia_puppet/hieradata"
puppetdb_terminus_url="http://apt-enterprise.puppetlabs.com/pool/lucid/extras/p/pe-puppetdb/pe-puppetdb-terminus_0.9.1-1puppet1_all.deb"
puppetdb_url="http://apt-enterprise.puppetlabs.com/pool/lucid/extras/p/pe-puppetdb/pe-puppetdb_0.9.1-1puppet1_all.deb"

#download and install puppet
mkdir -p $target_puppet_sourcedir
/usr/bin/curl $puppet_lucid_url |tar -xzf - -C $target_puppet_sourcedir  

# find the puppet enterprise installer
installer_command=`find /opt -name puppet-enterprise-installer`
hostname=`hostname`
# modify the answerfile
cat ../etc/xebia_puppet_install.conf.temp | sed "s/<hostname>/$hostname/g" >> ../etc/xebia_puppet_install.conf
#install puppet using the silent installfile in the ../etc dir
$installer_command -a ../etc/xebia_puppet_install.conf 

#modify puppet.conf
mv $puppet_conf_file $tmp_dir/puppet.conf
cat $tmp_dir/puppet.conf | sed -e ' s|modulepath = /etc/puppetlabs/puppet/modules:/opt/puppet/share/puppet/modules|modulepath = /etc/puppetlabs/puppet/modules:/opt/puppet/share/puppet/modules:'$xebia_puppet_base'/modules:'$xebia_puppet_base'/wrappers:'$xebia_puppet_base'/borrowed|g' >> $puppet_conf_file

#setup fog
cp ../etc/fog.conf ~/.fog

#setup hiera
mkdir -p $hiera_data_dir
mkdir -p $hiera_data_dir/hosts
cp ../etc/hiera.yaml $puppet_hiera_conf_file 

#download needed sources in to root home
outfile=`echo $puppet_lucid_url|nawk -F "/" '{print $(NF)}'`
/usr/bin/curl $puppet_lucid_url -o /root/${outfile}

puppetdb_terminus_url="http://apt-enterprise.puppetlabs.com/pool/lucid/extras/p/pe-puppetdb/pe-puppetdb-terminus_0.9.1-1puppet1_all.deb"
puppetdb_url="http://apt-enterprise.puppetlabs.com/pool/lucid/extras/p/pe-puppetdb/pe-puppetdb_0.9.1-1puppet1_all.deb"

puppetdb_deb=`echo $puppetdb_url|nawk -F "/" '{print $(NF)}'`
puppetdb_terminus_deb=`echo $puppetdb_terminus_url|nawk -F "/" '{print $(NF)}'`

/usr/bin/curl $puppetdb_url -o /var/tmp/$puppetdb_deb
/usr/bin/curl $puppetdb_terminus_url -o /var/tmp/$puppetdb_terminus_deb

dpkg -i /var/tmp/$puppetdb_deb
dpkg -i /var/tmp/$puppetdb_terminus_deb

cp ../etc/puppetdb.conf /etc/puppetlabs/puppet/puppetdb.conf
cp ../etc/routes.yaml /etc/puppetlabs/puppet/routes.yaml

#add puppetdb and autosign to puppet.conf
puppetdb_inserts="#xebia_puppet_install \n    autosign = true\n    storeconfigs = true\n    storeconfigs_backend = puppetdb\n #xebia_puppet_install"
mv $puppet_conf_file $tmp_dir/puppet.conf

sed "/\[master\]/a $puppetdb_inserts"  $tmp_dir/puppet.conf > $puppet_conf_file
