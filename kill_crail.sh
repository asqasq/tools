#!/bin/bash


sleep 10;
kill `ps xa|grep Dproc_namenode|awk '{print $1}'`
kill `ps xa|grep Dproc_datanode|awk '{print $1}'`


