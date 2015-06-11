#!/bin/bash

#Feed this script the sample name on the notDoneList

if [ ! -e submitList.txt ] 
then
  return 2 
fi

grep "$1" submitList.txt > /dev/null

if [ $? == 0 ]
then
  theLine=`grep "$1" submitList.txt` 
  name=`echo $theLine | awk '{ print $1 }'`
  jobid=`echo $theLine | awk '{ print $2 }'`
  starttime=`echo $theLine | awk '{ print $3 }'`
  nTries=`echo $theLine | awk '{ print $4 }'`
  return 1
fi

return 3
