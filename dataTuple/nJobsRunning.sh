#!/bin/bash 

condor_q $USER -const 'isDataTupleCMS3flagged==true' > jobsRunning.txt
nJobsRunning=`less jobsRunning.txt | wc -l`

if [ "$nJobsRunning" -gt "2000" ]
then
  echo "Data Tuple Warning!  $USER is running more than 2000 jobs." | /bin/mail -r "george@physics.ucsb.edu" -s "[dataTuple] warning" "george@physics.ucsb.edu, jgran@physics.ucsb.edu, mark.derdzinski@gmail.com" 
fi
