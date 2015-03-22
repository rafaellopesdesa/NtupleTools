#!/bin/bash 

condor_q $USER -const 'isDataTupleCMS3flagged==true' > jobsRunning.txt
nJobsRunning=`awk 'END{print $1}' jobsRunning.txt`
if [ "$nJobsRunning" -gt "2000" ]
then
  echo "Data Tuple Warning!  You are running more than 2000 jobs." | /bin/mail -r "george@physics.ucsb.edu" -s "[dataTuple] warning" "george@physics.ucsb.edu, jgran@physics.ucsb.edu" 
fi
        
