#!/bin/bash

sha512sum -c apache-crail-1.1-incubating-bin.tar.gz.sha512
if [ $? -ne 0 ]; then
  echo "ERROR: CHECKSUM for apache-crail-1.1-incubating-bin.tar.gz WRONG";
  exit 1;
fi

sha512sum -c apache-crail-1.1-incubating-src.tar.gz.sha512

if [ $? -ne 0 ]; then
  echo "ERROR: CHECKSUM for apache-crail-1.1-incubating-src.tar.gz WRONG";
  exit 2;
fi

gpg --verify apache-crail-1.1-incubating-bin.tar.gz.asc apache-crail-1.1-incubating-bin.tar.gz

if [ $? -ne 0 ]; then
  echo "ERROR: SIGNATURE for apache-crail-1.1-incubating-bin.tar.gz WRONG";
  exit 3;
fi

gpg --verify apache-crail-1.1-incubating-src.tar.gz.asc apache-crail-1.1-incubating-src.tar.gz

if [ $? -ne 0 ]; then
  echo "ERROR: SIGNATURE for apache-crail-1.1-incubating-src.tar.gz WRONG";
  exit 4;
fi

echo ""
echo ""
echo "Checksums and signatures are all valid"
echo ""
echo ""

rm -rf apache-crail-1.1-incubating

tar xvzf apache-crail-1.1-incubating-bin.tar.gz
mkdir -p /tmp/crail/data
mkdir -p /tmp/crail/cache

echo "crail.namenode.address            crail://localhost:9060" > apache-crail-1.1-incubating/conf/crail-site.conf
echo "crail.cachepath                   /tmp/crail/cache" >> apache-crail-1.1-incubating/conf/crail-site.conf
echo "crail.cachelimit                  0" >> apache-crail-1.1-incubating/conf/crail-site.conf
echo "crail.storage.tcp.interface       enp0s31f6" >> apache-crail-1.1-incubating/conf/crail-site.conf
echo "crail.storage.tcp.datapath        /tmp/crail/data" >> apache-crail-1.1-incubating/conf/crail-site.conf
echo "crail.storage.tcp.storagelimit    1073741824" >> apache-crail-1.1-incubating/conf/crail-site.conf

cp apache-crail-1.1-incubating/conf/core-site.xml.template apache-crail-1.1-incubating/conf/core-site.xml

(cd apache-crail-1.1-incubating && CRAIL_HOME=`pwd` ./bin/crail namenode & )
sleep 5;

(cd apache-crail-1.1-incubating && CRAIL_HOME=`pwd` ./bin/crail datanode & )
sleep 5;


(cd apache-crail-1.1-incubating && CRAIL_HOME=`pwd` ./bin/crail fs -touchz /testfile.txt  )
(cd apache-crail-1.1-incubating && CRAIL_HOME=`pwd` ./bin/crail fs -ls / | grep testfile.txt )

if [ $? -ne 0 ]; then
  echo "ERROR: Cannot correctly execute binary release";
  exit 5;
fi


sleep 10;
kill `ps xa|grep Dproc_namenode|awk '{print $1}'`
kill `ps xa|grep Dproc_datanode|awk '{print $1}'`



rm -rf apache-crail-1.1-incubating

echo ""
echo ""
echo "Executing binary release (namenode, datanode, client) PASSED"
echo ""
echo ""


tar xvzf apache-crail-1.1-incubating-src.tar.gz 

(cd apache-crail-1.1-incubating-src && mvn -DskipTests package)
if [ $? -ne 0 ]; then
  echo "ERROR: Cannot compile the source tarball";
  exit 6;
fi


