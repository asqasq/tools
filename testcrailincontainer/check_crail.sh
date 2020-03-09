#!/bin/bash


function usage() {
  echo " -i|--disni <link> -s|--disnibranch <branch> -a|--darpc <link> -p|--darpcbranch <branch> -c|--crail <link> -b|--crailbranch <branch>";
  exit 1;
}

while (( "$#" )); do
  case "$1" in
    -i|--disni)
      DISNI=$2
      shift 2
      ;;
    -s|--disnibranch)
      DISNIBRANCH=$2
      shift 2
      ;;
    -a|--darpc)
      DARPC=$2
      shift 2
      ;;
    -p|--darpcbranch)
      DARPCBRANCH=$2
      shift 2
      ;;
    -c|--crail)
      CRAIL=$2
      shift 2
      ;;
    -b|--crailbranch)
      CRAILBRANCH=$2
      shift 2
      ;;
    -h|--help)
      usage
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done


if [ -z $DISNI ]; then
  echo "Please specify the github link to DiSNI";
  exit 1;
fi

if [ -z $DISNIBRANCH ]; then
  echo "Please specify the DiSNI branch to checkout";
  exit 1;
fi

if [ -z $DARPC ]; then
  echo "Please specify the github link to DaRPC";
  exit 1;
fi

if [ -z $DARPCBRANCH ]; then
  echo "Please specify the DaRPC branch to checkout";
  exit 1;
fi

if [ -z $CRAIL ]; then
  echo "Please specify the github link to Crail";
  exit 1;
fi

if [ -z $CRAILBRANCH ]; then
  echo "Please specify the Crail branch to checkout";
  exit 1;
fi

#Install DiSNI
echo "git clone $DISNI from branch $DISNIBRANCH"
cd /
git clone $DISNI /disni
cd /disni
git checkout $DISNIBRANCH
mvn -DskipTests install
cd libdisni && ./autoprepare.sh && ./configure --with-jdk=$JAVA_HOME && make install


#Install DaRPC
echo "git clone $DARPC from branch $DARPCBRANCH"
cd /
git clone $DARPC /darpc
cd /darpc
git checkout $DARPCBRANCH
mvn -DskipTests install

#Install Crail
echo "git clone $CRAIL from branch $CRAILBRANCH"
cd /
git clone $CRAIL /incubator-crail
cd /incubator-crail
git checkout $CRAILBRANCH
mvn -DskipTests package

#Install Crail
rm -rf /crail
v=`xmllint --xpath "string(/*[local-name()='project']/*[local-name()='version'])" /incubator-crail/pom.xml`
mv /incubator-crail/assembly/target/apache-crail-${v}-bin/apache-crail-${v} /crail




mkdir -p /tmp/crail/data
mkdir -p /tmp/crail/cache

netiface="eth0"


echo "crail.namenode.address            crail://localhost:9060" > $CRAIL_HOME/conf/crail-site.conf
echo "crail.cachepath                   /tmp/crail/cache" >> $CRAIL_HOME/conf/crail-site.conf
echo "crail.cachelimit                  0" >> $CRAIL_HOME/conf/crail-site.conf
echo "crail.storage.tcp.interface       ${netiface}" >> $CRAIL_HOME/conf/crail-site.conf
echo "crail.storage.tcp.datapath        /tmp/crail/data" >> $CRAIL_HOME/conf/crail-site.conf
echo "crail.storage.tcp.storagelimit    1073741824" >> $CRAIL_HOME/conf/crail-site.conf

cat $CRAIL_HOME/conf/crail-site.conf


cp $CRAIL_HOME/conf/core-site.xml.template $CRAIL_HOME/conf/core-site.xml

(cd $CRAIL_HOME && CRAIL_HOME=`pwd` ./bin/crail namenode & )
sleep 5;

(cd $CRAIL_HOME && CRAIL_HOME=`pwd` ./bin/crail datanode & )
sleep 5;


(cd $CRAIL_HOME && ./bin/crail fs -touchz /testfile.txt  )
(cd $CRAIL_HOME && ./bin/crail fs -ls / | grep testfile.txt )

if [ $? -ne 0 ]; then
  echo "ERROR: Cannot correctly execute Crail";
  exit 5;
fi


sleep 10;
kill `ps xa|grep Dproc_namenode|awk '{print $1}'`
kill `ps xa|grep Dproc_datanode|awk '{print $1}'`




echo ""
echo ""
echo "Executing Crail (namenode, datanode, client) PASSED"
echo ""
echo ""




echo ""
echo ""
echo "ALL TESTS PASSED"
echo ""
echo ""
