#!/bin/bash

if [ -e /nfs-7/userdata/dataTuple/suicide.txt ] 
then
  if [ -e /nfs-7/userdata/dataTuple/running.pid ]
  then
    while read line 
    do
    if [ `echo $line | awk '{print $1}'` == "PID" ] 
    then
      jobID=$line
    fi
    echo "jobID: $jobID"
    done < /nfs-7/userdata/dataTuple/running.pid
  fi

  rm -r /nfs-7/userdata/dataTuple/running.pid > /dev/null 2>&1
  crontab -r 
fi
