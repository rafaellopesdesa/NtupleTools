#!/bin/bash

#Feed this script the sample name on the notDoneList

while read line
do
  name=`echo $line | awk '{ print $1 }'`
  if [ $name == $1 ] 
  then
    exit 1
  else
    exit 2
  fi
done < submitList.txt

exit 3
