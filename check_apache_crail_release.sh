#!/bin/bash

# Make sure to start with a clean tree
rm -rf apache-crail-1.1-incubating
rm -rf apache-crail-1.1-incubating-src





tar xvzf apache-crail-1.1-incubating-bin.tar.gz


mkdir -p /tmp/crail/data
mkdir -p /tmp/crail/cache

netiface=`ip -4 -o  address|grep -v 127.0|grep inet|head -1|awk '{print $2}'`


echo "crail.namenode.address            crail://localhost:9060" > apache-crail-1.1-incubating/conf/crail-site.conf
echo "crail.cachepath                   /tmp/crail/cache" >> apache-crail-1.1-incubating/conf/crail-site.conf
echo "crail.cachelimit                  0" >> apache-crail-1.1-incubating/conf/crail-site.conf
echo "crail.storage.tcp.interface       ${netiface}" >> apache-crail-1.1-incubating/conf/crail-site.conf
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

rm -rf /tmp/crail/data/*
rm -rf /tmp/crail/cache/*


echo "crail.namenode.address            crail://localhost:9060" > apache-crail-1.1-incubating-src/assembly/target/apache-crail-1.1-incubating-bin/apache-crail-1.1-incubating/conf/crail-site.conf
echo "crail.cachepath                   /tmp/crail/cache" >> apache-crail-1.1-incubating-src/assembly/target/apache-crail-1.1-incubating-bin/apache-crail-1.1-incubating/conf/crail-site.conf
echo "crail.cachelimit                  0" >> apache-crail-1.1-incubating-src/assembly/target/apache-crail-1.1-incubating-bin/apache-crail-1.1-incubating/conf/crail-site.conf
echo "crail.storage.tcp.interface       ${netiface}" >> apache-crail-1.1-incubating-src/assembly/target/apache-crail-1.1-incubating-bin/apache-crail-1.1-incubating/conf/crail-site.conf
echo "crail.storage.tcp.datapath        /tmp/crail/data" >> apache-crail-1.1-incubating-src/assembly/target/apache-crail-1.1-incubating-bin/apache-crail-1.1-incubating/conf/crail-site.conf
echo "crail.storage.tcp.storagelimit    1073741824" >> apache-crail-1.1-incubating-src/assembly/target/apache-crail-1.1-incubating-bin/apache-crail-1.1-incubating/conf/crail-site.conf

cp apache-crail-1.1-incubating-src/assembly/target/apache-crail-1.1-incubating-bin/apache-crail-1.1-incubating/conf/core-site.xml.template \
   apache-crail-1.1-incubating-src/assembly/target/apache-crail-1.1-incubating-bin/apache-crail-1.1-incubating/conf/core-site.xml



(cd apache-crail-1.1-incubating-src/assembly/target/apache-crail-1.1-incubating-bin/apache-crail-1.1-incubating && CRAIL_HOME=`pwd` ./bin/crail namenode & )
sleep 5;

(cd apache-crail-1.1-incubating-src/assembly/target/apache-crail-1.1-incubating-bin/apache-crail-1.1-incubating && CRAIL_HOME=`pwd` ./bin/crail datanode & )
sleep 5;


(cd apache-crail-1.1-incubating-src/assembly/target/apache-crail-1.1-incubating-bin/apache-crail-1.1-incubating && CRAIL_HOME=`pwd` ./bin/crail fs -touchz /testfile.txt  )
(cd apache-crail-1.1-incubating-src/assembly/target/apache-crail-1.1-incubating-bin/apache-crail-1.1-incubating && CRAIL_HOME=`pwd` ./bin/crail fs -ls / | grep testfile.txt )

if [ $? -ne 0 ]; then
  echo "ERROR: Cannot correctly execute source release";
  exit 6;
fi


sleep 10;
kill `ps xa|grep Dproc_namenode|awk '{print $1}'`
kill `ps xa|grep Dproc_datanode|awk '{print $1}'`




echo ""
echo ""
echo "Executing source release (namenode, datanode, client) PASSED"
echo ""
echo ""

# Check signatures and checksums
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


#Check tarball for licenses, ...
ls -l apache-crail-1.1-incubating/LICENSE > /dev/null

if [ $? -ne 0 ]; then
  echo "ERROR: MISSING LICENSE file in binary release";
  exit 11;
fi
ls -l apache-crail-1.1-incubating/licenses > /dev/null

if [ $? -ne 0 ]; then
  echo "ERROR: MISSING licenses directory in binary release";
  exit 11;
fi


lcerrbin=0;
for f in `ls apache-crail-1.1-incubating/jars/*.jar`; do
  b=`basename $f`;
  j=`echo "$b"|grep -v '^crail*'`;
  if [ ! -z  $j  ]; then
    grep "$j" apache-crail-1.1-incubating/LICENSE > /dev/null;
    if [ $? -ne 0 ]; then
      echo "Missing license for $j in binary release";
      lcerrbin=1;
    fi
  fi
done

if [ $lcerrbin -ne 0 ]; then
  echo "WARNING: MISSING LICENSES in binary release";
#  exit 10;
fi


ls -l apache-crail-1.1-incubating-src/LICENSE > /dev/null

if [ $? -ne 0 ]; then
  echo "ERROR: MISSING LICENSE file in source release";
  exit 11;
fi
ls -l apache-crail-1.1-incubating-src/licenses > /dev/null

if [ $? -ne 0 ]; then
  echo "ERROR: MISSING licenses directory in source release";
  exit 11;
fi

lcerrsrc=0;
for f in `ls apache-crail-1.1-incubating-src/assembly/target/apache-crail-1.1-incubating-bin/apache-crail-1.1-incubating/jars/*.jar`; do
  b=`basename $f`;
  j=`echo "$b"|grep -v '^crail*'`;
  if [ ! -z  $j  ]; then
    grep "$j" apache-crail-1.1-incubating-src/LICENSE-binary > /dev/null;
    if [ $? -ne 0 ]; then
      echo "Missing license for $j in source release";
      lcerrsrc=1;
    fi
  fi
done






rm -rf apache-crail-1.1-incubating
rm -rf apache-crail-1.1-incubating-src
rm -rf /tmp/crail/data
rm -rf /tmp/crail/cache


if [ $lcerrbin -ne 0 ]; then
  echo "WARNING: MISSING LICENSES in binary release";
#  exit 10;
fi

if [ $lcerrsrc -ne 0 ]; then
  echo "WARNING: MISSING LICENSES in source release";
#  exit 10;
fi

if [ $lcerrsrc -ne 0 -o $lcerrbin -ne 0 ]; then
  exit 10;
fi


echo ""
echo ""
echo "ALL TESTS PASSED"
echo ""
echo ""
