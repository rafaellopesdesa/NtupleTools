#!/bin/bash

#Feed this script the sample name on the notDoneList

while read line
do
  if [ ! -e failureList.txt ] 
  then
    return 2 
  fi
  name=`echo $line | awk '{ print $1 }'`
  if [ "$name" == "$1" ] 
  then
    return 1
  fi
done < failureList.txt

return 3
