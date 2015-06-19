#!/bin/bash

if [ $# -eq 0 ] 
  then 
    echo "No BASEPATH specified in suicide.sh!"
    exit
  else
    BASEPATH=$1
fi

if [ -e $BASEPATH/suicide.txt ] 
then
  if [ -e $BASEPATH/running.pid ]
  then
    while read line 
    do
    if [ `echo $line | awk '{print $1}'` == "PID" ] 
    then
      jobID=$line
    fi
    echo "jobID: $jobID"
    done < $BASEPATH/running.pid
  fi

  rm -r $BASEPATH/running.pid > /dev/null 2>&1
  crontab -r 
fi
