#!/bin/bash

#This is the manager that calls all the other pieces.  This should itself be called every N minutes.  

#Make sure cms3withCondor exists
if [ ! -d cms3withCondor ] 
then
  cp -r ../cms3withCondor .
fi

#1. DBS query to generate masterList with files on input.txt (DONE. GenerateMasterList.sh)
. GenerateMasterList.sh

#2. Diff between masterList and completedList to make notDoneList. (DONE. makeNotDoneList.sh)
. makeNotDoneList.sh

#3. condor_q makes runningList and heldList. Jobs on the heldList are killed. (DONE. checkStatus.sh)
. checkStatus.sh

#4. Cycle through files on notDoneList. (DONE)
rm filesToSubmit.txt &> /dev/null
while read line
do
  #a. See if each job is on submitList. If no, mark the job for submission and on to step 5. (DONE)
  . isOnSubmitList.sh $line
  if [ $? != 1 ] 
  then
    echo $line >> filesToSubmit.txt
    continue
  fi

  #b. Otherwise, it's on the submitList. Get the jobID from there and see if the job is running.
  condor_q $jobid > temp.txt
  sed -i '1,4d' temp.txt
  if [ -s temp.txt ]; then isRunning=true; else isRunning=false; fi

  #c. If job is on run list, check time. If has been running for more than 24 hours, kill it, mark for submission, and on to step 5.
  if [ $isRunning == true ] 
  then
    tooMuchTime=$(python checkTime.py $starttime 2>&1)
    if [ $tooMuchTime == "true" ]
    then
      condor_rm $jobid
      echo $line >> filesToSubmit.txt
      continue
    fi
  fi

  #d. If not on run list, check if it's done. If not done, mark for submission and on to step 5.
  if [ $isRunning == false ] 
  then
    if [ ! -e /hadoop/cms/store/user/$USER/condor/dataNtupling/dataTuple/ntuple_${number}.root ] 
    then
      echo $line >> filesToSubmit.txt
      continue
    fi
    if [ -e /hadoop/cms/store/user/$USER/condor/dataNtupling/dataTuple/ntuple_${number}.root ] 
    then
      . checkFile.sh
      continue
    fi
  fi

  #e. If job is done, do quality checks. If fails, delete the output, mark for submission, and on to step 5. (JASON)

  #f. If passes quality checks, then update the done list and we're done. (JASON)

done < notDoneList.txt

#5. Submit all the jobs that have been marked for submission
if [ -e filesToSubmit.txt ] 
then 
  while read line
  do
    #a. Submit them
    . submit.sh filesToSubmit.txt

    #b. Verify all jobs submitted properly (??)

    #c. Update submitted list
    . isOnSubmitList.sh $line
    currentTime=`date +%s`
    if [ $? != 1 ] 
    then
      echo "$line $jobid $currentTime 1" >> submitList.sh
      continue
    else
      line_escaped=`echo $line | sed 's,/,\\/,g'`
      sed -i "/$line_escaped/d" submitList.sh
      let "nTries=$nTries+1"
      echo "$line $jobid $currentTime $nTries" >> submitList.sh
      continue
    fi
  done < filesToSubmit.sh

fi
