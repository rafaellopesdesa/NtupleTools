#!/bin/bash

#Feed this script the sample name on the notDoneList

while read line
do
  name=`echo $line | awk '{ print $1 }'`
  jobid=`echo $line | awk '{ print $2 }'`
  starttime=`echo $line | awk '{ print $3 }'`
  nTries=`echo $line | awk '{ print $4 }'`
  if [ $name == $1 ] 
  then
    return 1
  else
    return 2
  fi
done < submitList.txt

return 3
