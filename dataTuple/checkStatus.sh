#!/bin/bash

#Run condor_q to get list of running jobs
condor_q $USERNAME > temp.txt
sed -i '1,4d' temp.txt
sed -i '$d' temp.txt
sed -i '$d' temp.txt

#Delete old test files
rm runningList.txt
rm heldList.txt

#Read condor_q output to fill lists.  
while read line
do
  if [ `echo $line | awk '{ print $6 }'` == "R" ]
  then 
    echo `echo $line | awk '{ print $1 }'` >> runningList.txt
  elif [ `echo $line | awk '{ print $6 }'` == "C" ]
    cat `echo $line | awk '{ print $1 }'` > runningList.txt
  elif [ `echo $line | awk '{ print $6 }'` == "I" ]
    cat `echo $line | awk '{ print $1 }'` > runningList.txt
  elif [ `echo $line | awk '{ print $6 }'` == "H" ]
    cat `echo $line | awk '{ print $1 }'` > heldList.txt
  fi
done < temp.txt

#Delete held jobs
while read line
do
  condor_rm $line
done < heldList.txt
