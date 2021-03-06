#!/bin/bash

#Run condor_q to get list of running jobs
condor_q $USER -const 'isDataTupleCMS3flagged==true' > temp_status.txt
sed -i '1,4d' temp_status.txt
sed -i '$d' temp_status.txt
sed -i '$d' temp_status.txt

#Delete old test files
rm runningList.txt 2>/dev/null
rm heldList.txt 2>/dev/null

#Read condor_q output to fill lists.  
while read line
do
  if [ `echo $line | awk '{ print $6 }'` == "H" ]
  then
    echo `echo $line | awk '{ print $1 }'` >> heldList.txt
  fi
done < temp_status.txt

rm temp_status.txt

#Delete held jobs
if [ -e heldList.txt ]
then
  while read line
  do
    condor_rm $line
  done < heldList.txt
  rm heldList.txt
fi

