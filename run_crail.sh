#!/bin/bash


mkdir -p /tmp/crail/data
mkdir -p /tmp/crail/cache

netiface=`ip -4 -o  address|grep -v 127.0|grep inet|head -1|awk '{print $2}'`


echo "crail.namenode.address            crail://localhost:9060" > conf/crail-site.conf
echo "crail.cachepath                   /tmp/crail/cache" >> conf/crail-site.conf
echo "crail.cachelimit                  0" >> conf/crail-site.conf
echo "crail.storage.tcp.interface       ${netiface}" >> conf/crail-site.conf
echo "crail.storage.tcp.datapath        /tmp/crail/data" >> conf/crail-site.conf
echo "crail.storage.tcp.storagelimit    1073741824" >> conf/crail-site.conf

cp conf/core-site.xml.template conf/core-site.xml

(cd . &&  CRAIL_HOME=`pwd` ./bin/crail namenode & )
sleep 5;

(cd .  && CRAIL_HOME=`pwd` ./bin/crail datanode & )
sleep 5;


(cd . && CRAIL_HOME=`pwd` ./bin/crail fs -touchz /testfile.txt  )
(cd . && CRAIL_HOME=`pwd` ./bin/crail fs -ls / | grep testfile.txt )

if [ $? -ne 0 ]; then
  echo "ERROR: Cannot correctly execute binary release";
  exit 5;
fi

