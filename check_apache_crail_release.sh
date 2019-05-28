#!/bin/bash

if [ -z $1 ]; then
  echo "Please specify a Crail version in this format: apache-crail-1.2-incubating-SNAPSHOT without the .tar.gz suffix.";
  exit 1;
fi

crailname=$1

# Make sure to start with a clean tree
rm -rf $crailname
rm -rf $crailname-src





tar xvzf $crailname-bin.tar.gz


mkdir -p /tmp/crail/data
mkdir -p /tmp/crail/cache

netiface=`ip -4 -o  address|grep -v 127.0|grep inet|head -1|awk '{print $2}'`


echo "crail.namenode.address            crail://localhost:9060" > $crailname/conf/crail-site.conf
echo "crail.cachepath                   /tmp/crail/cache" >> $crailname/conf/crail-site.conf
echo "crail.cachelimit                  0" >> $crailname/conf/crail-site.conf
echo "crail.storage.tcp.interface       ${netiface}" >> $crailname/conf/crail-site.conf
echo "crail.storage.tcp.datapath        /tmp/crail/data" >> $crailname/conf/crail-site.conf
echo "crail.storage.tcp.storagelimit    1073741824" >> $crailname/conf/crail-site.conf

cp $crailname/conf/core-site.xml.template $crailname/conf/core-site.xml

(cd $crailname && CRAIL_HOME=`pwd` ./bin/crail namenode & )
sleep 5;

(cd $crailname && CRAIL_HOME=`pwd` ./bin/crail datanode & )
sleep 5;


(cd $crailname && CRAIL_HOME=`pwd` ./bin/crail fs -touchz /testfile.txt  )
(cd $crailname && CRAIL_HOME=`pwd` ./bin/crail fs -ls / | grep testfile.txt )

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


tar xvzf $crailname-src.tar.gz 

(cd $crailname-src && mvn -DskipTests package)
if [ $? -ne 0 ]; then
  echo "ERROR: Cannot compile the source tarball";
  exit 6;
fi

rm -rf /tmp/crail/data/*
rm -rf /tmp/crail/cache/*


echo "crail.namenode.address            crail://localhost:9060" > $crailname-src/assembly/target/$crailname-bin/$crailname/conf/crail-site.conf
echo "crail.cachepath                   /tmp/crail/cache" >> $crailname-src/assembly/target/$crailname-bin/$crailname/conf/crail-site.conf
echo "crail.cachelimit                  0" >> $crailname-src/assembly/target/$crailname-bin/$crailname/conf/crail-site.conf
echo "crail.storage.tcp.interface       ${netiface}" >> $crailname-src/assembly/target/$crailname-bin/$crailname/conf/crail-site.conf
echo "crail.storage.tcp.datapath        /tmp/crail/data" >> $crailname-src/assembly/target/$crailname-bin/$crailname/conf/crail-site.conf
echo "crail.storage.tcp.storagelimit    1073741824" >> $crailname-src/assembly/target/$crailname-bin/$crailname/conf/crail-site.conf

cp $crailname-src/assembly/target/$crailname-bin/$crailname/conf/core-site.xml.template \
   $crailname-src/assembly/target/$crailname-bin/$crailname/conf/core-site.xml



(cd $crailname-src/assembly/target/$crailname-bin/$crailname && CRAIL_HOME=`pwd` ./bin/crail namenode & )
sleep 5;

(cd $crailname-src/assembly/target/$crailname-bin/$crailname && CRAIL_HOME=`pwd` ./bin/crail datanode & )
sleep 5;


(cd $crailname-src/assembly/target/$crailname-bin/$crailname && CRAIL_HOME=`pwd` ./bin/crail fs -touchz /testfile.txt  )
(cd $crailname-src/assembly/target/$crailname-bin/$crailname && CRAIL_HOME=`pwd` ./bin/crail fs -ls / | grep testfile.txt )

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
sha512sum -c $crailname-bin.tar.gz.sha512
if [ $? -ne 0 ]; then
  echo "ERROR: CHECKSUM for $crailname-bin.tar.gz WRONG";
  exit 1;
fi

sha512sum -c $crailname-src.tar.gz.sha512

if [ $? -ne 0 ]; then
  echo "ERROR: CHECKSUM for $crailname-src.tar.gz WRONG";
  exit 2;
fi

gpg --verify $crailname-bin.tar.gz.asc $crailname-bin.tar.gz

if [ $? -ne 0 ]; then
  echo "ERROR: SIGNATURE for $crailname-bin.tar.gz WRONG";
  exit 3;
fi

gpg --verify $crailname-src.tar.gz.asc $crailname-src.tar.gz

if [ $? -ne 0 ]; then
  echo "ERROR: SIGNATURE for $crailname-src.tar.gz WRONG";
  exit 4;
fi

echo ""
echo ""
echo "Checksums and signatures are all valid"
echo ""
echo ""


#Check tarball for licenses, ...
ls -l $crailname/LICENSE > /dev/null

if [ $? -ne 0 ]; then
  echo "ERROR: MISSING LICENSE file in binary release";
  exit 11;
fi
ls -l $crailname/licenses > /dev/null

if [ $? -ne 0 ]; then
  echo "ERROR: MISSING licenses directory in binary release";
  exit 11;
fi


lcerrbin=0;
for f in `ls $crailname/jars/*.jar`; do
  b=`basename $f`;
  j=`echo "$b"|grep -v '^crail*'`;
  if [ ! -z  $j  ]; then
    grep "$j" $crailname/LICENSE > /dev/null;
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


ls -l $crailname-src/LICENSE > /dev/null

if [ $? -ne 0 ]; then
  echo "ERROR: MISSING LICENSE file in source release";
  exit 11;
fi
ls -l $crailname-src/licenses > /dev/null

if [ $? -ne 0 ]; then
  echo "ERROR: MISSING licenses directory in source release";
  exit 11;
fi

lcerrsrc=0;
for f in `ls $crailname-src/assembly/target/$crailname-bin/$crailname/jars/*.jar`; do
  b=`basename $f`;
  j=`echo "$b"|grep -v '^crail*'`;
  if [ ! -z  $j  ]; then
    grep "$j" $crailname-src/LICENSE-binary > /dev/null;
    if [ $? -ne 0 ]; then
      echo "Missing license for $j in source release";
      lcerrsrc=1;
    fi
  fi
done






rm -rf $crailname
rm -rf $crailname-src
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
