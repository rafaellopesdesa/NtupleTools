#!/bin/bash 

tac cms3withCondor/submit_logs/condor_$1.log > temp_tac.log #reverse the file

#Feed this program the date and number
found_cluster=false
found_proc=false
while read line
do
  if [ `echo $line | awk '{ print $1 }'` == "Cluster" ] 
  then
    cluster=`echo $line | awk '{ print $3 }'`
    found_cluster=true
  elif [ `echo $line | awk '{ print $1 }'` == "Proc" ] 
  then
    process=`echo $line | awk '{ print $3 }'`
    found_proc=true
  fi

  if [[ "$found_cluster" = true  && "$found_proc" = true ]] ; then
    break
  fi
done < temp_tac.log

rm temp_tac.log
#done < cms3withCondor/submit_logs/condor_$1.log

jobid=$cluster.$process
