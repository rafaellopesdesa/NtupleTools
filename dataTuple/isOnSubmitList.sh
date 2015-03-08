#!/bin/bash

#Feed this script the sample name on the notDoneList

if [ ! -e submitList.txt ] 
then
  return 2 
fi

while read line
do
  name=`echo $line | awk '{ print $1 }'`
  jobid=`echo $line | awk '{ print $2 }'`
  starttime=`echo $line | awk '{ print $3 }'`
  nTries=`echo $line | awk '{ print $4 }'`
  if [ "$name" == "$1" ] 
  then
    return 1
  fi
done < submitList.txt

return 3
