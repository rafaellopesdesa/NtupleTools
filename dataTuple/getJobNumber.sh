#!/bin/bash 

#Feed this program the date and number
while read line
do
  if [ `echo $line | awk '{ print $1 }'` == "Cluster" ] 
  then
    cluster=`echo $line | awk '{ print $3 }'`
  elif [ `echo $line | awk '{ print $1 }'` == "Proc" ] 
  then
    process=`echo $line | awk '{ print $3 }'`
  fi
done < cms3withCondor/$2/condorLog_$1.log 

jobid=$cluster.$process
