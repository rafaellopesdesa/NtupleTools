#!/bin/bash

#Feed this script the sample name on the notDoneList

while read line
do
  name=`echo $line | awk '{ print $1 }'`
  if [ "$name" == "$1" ] 
  then
    return 1
  else
    return 2
  fi
done < failureList.txt

return 3
