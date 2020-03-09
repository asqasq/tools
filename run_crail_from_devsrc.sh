#!/bin/bash


echo ""
echo ""
echo ""
echo "--------------------------------------------------------------------------"
echo ""
echo ""
echo "Run this script from the root of your development source tree to"
echo "start a Crail instance starting with a dot to ensure that"
echo "variables get exportet."
echo "Example:"
echo "user@machine:~/incubator-crail$ . ~/tools/run_crail_from_devsrc.sh"
echo ""
echo ""
echo "--------------------------------------------------------------------------"
echo ""
echo ""

sleep 2


netiface=`ip -4 -o  address|grep -v 127.0|grep inet|head -1|awk '{print $2}'`


rm -rf /tmp/crail/data/*
rm -rf /tmp/crail/cache/*

mkdir -p /tmp/crail

rsync -r assembly/target/apache-crail-*-incubating-SNAPSHOT-bin/apache-crail-*-incubating-SNAPSHOT/ /tmp/crail

mkdir -p /tmp/crail/data
mkdir -p /tmp/crail/cache


echo "crail.namenode.address            crail://localhost:9060" > /tmp/crail/conf/crail-site.conf
echo "crail.cachepath                   /tmp/crail/cache" >> /tmp/crail/conf/crail-site.conf
echo "crail.cachelimit                  0" >> /tmp/crail/conf/crail-site.conf
echo "crail.storage.tcp.interface       ${netiface}" >> /tmp/crail/conf/crail-site.conf
echo "crail.storage.tcp.datapath        /tmp/crail/data" >> /tmp/crail/conf/crail-site.conf
echo "crail.storage.tcp.storagelimit    1073741824" >> /tmp/crail/conf/crail-site.conf

cp /tmp/crail/conf/core-site.xml.template \
   /tmp/crail/conf/core-site.xml


export CRAIL_HOME=/tmp/crail
export PATH=$CRAIL_HOME/bin:$PATH

crail namenode &
sleep 5;
crail datanode &


#crail fs -ls /




#kill `ps xa|grep Dproc_namenode|awk '{print $1}'`
#kill `ps xa|grep Dproc_datanode|awk '{print $1}'`


