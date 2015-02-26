#!/bin/bash

#This is the manager that calls all the other pieces.  This should itself be called every N minutes.  

#1. DBS query to generate masterList with files on input.txt (JASON)


#2. Diff between masterList and completedList to make notDoneList. (DONE. makeNotDoneList.sh)
#. makeNotDoneList.sh

#3. condor_q makes runningList and heldList. Jobs on the heldList are killed. (DONE. checkStatus.sh)
#. checkStatus.sh

#4. Cycle through files on notDoneList.
rm filesToSubmit.txt &> /dev/null
while read line
do
  #a. See if each job is on submitList. If no, mark the job for submission and on to step 5.
  . isOnSubmitList.sh $line
  if [ $? != 1 ] 
  then
    echo $line >> filesToSubmit.txt
  fi
  #Otherwise, it's on the submitList. Get the jobID from there and see if the job is running.

done < notDoneList.txt

#5. Submit all the jobs thata have been marked for submission
if [ -e filesToSubmit.txt ] 
then 
  . submit.sh filesToSubmit.txt
fi

#To do: update the submit list after we're sure it was submitted properly.  Look at logs to get the job ID

#If job is on run list, check time. If has been running for more than 24 hours, kill it, submit it, update the submit list, and we're done.
#If not on run list, check if it's done. If not done, submit it, update the submit list, and we're done.
#If job is done, do quality checks. If fails, delete the output and we're done. If passes, then update the done list and we're done. (JASON)
