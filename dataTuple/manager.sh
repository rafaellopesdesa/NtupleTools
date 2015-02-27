#!/bin/bash

#This is the manager that calls all the other pieces.  This should itself be called every N minutes.  

#Make sure cms3withCondor exists
if [ ! -d cms3withCondor ] 
then
  cp -r ../cms3withCondor .
fi

if [ ! -e submitList.txt ] 
then
  touch submitList.txt
fi

#1. DBS query to generate masterList with files on input.txt (DONE. GenerateMasterList.sh)
#. GenerateMasterList.sh

#2. Diff between masterList and completedList to make notDoneList. (DONE. makeNotDoneList.sh)
#. makeNotDoneList.sh

#3. condor_q makes runningList and heldList. Jobs on the heldList are killed. (DONE. checkStatus.sh)
. checkStatus.sh

#4. Cycle through files on notDoneList. (DONE)
rm filesToSubmit.txt 2> /dev/null
while read line
do
  currentFile=$line
  #a. See if each job is on submitList. If no, mark the job for submission and on to step 5. (DONE)
  . isOnSubmitList.sh $currentFile
  if [ $? != 1 ] 
  then
    echo $currentFile >> filesToSubmit.txt
    continue
  fi

  #b. Otherwise, it's on the submitList. Get the jobID from there and see if the job is running.
  echo $jobid
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
      echo $currentFile >> filesToSubmit.txt
      continue
    fi
  fi

  #d. If not on run list, check if it's done. If not done, mark for submission and on to step 5.
  if [ $isRunning == false ] 
  then
    if [ ! -e /hadoop/cms/store/user/$USER/condor/dataNtupling/dataTuple/$currentFile ] 
    then
      echo `echo $currentFile | awk ' { print $1 }'` >> filesToSubmit.txt
      continue
    else
      . checkFile.sh /hadoop/cms/store/user/$USER/condor/dataNtupling/dataTuple/$currentFile
      continue
    fi
  fi

done < notDoneList.txt

#5. Submit all the jobs that have been marked for submission
counter=0;
currentTime=`date +%s`
if [ -e filesToSubmit.txt ] 
then 
  while read line
  do
    currentLine=$line
    let "counter=$counter+1"
    #a. Submit them
    mkdir cms3withCondor/$currentTime
    outputName=$(python getFileName.py $currentLine 2>&1)
    . submit.sh filesToSubmit.txt $currentTime $outputName
    #b. Verify all jobs submitted properly (??)

    #c. Update submitted list
    . getJobNumber.sh $counter $currentTime
    . isOnSubmitList.sh $currentLine
    if [ $? != 1 ] 
    then
      . getJobNumber.sh $counter $currentTime
      echo "currentLine"
      echo $currentLine
      echo "$currentLine $jobid $currentTime 1" >> submitList.txt
      continue
    else
      . getJobNumber.sh $counter $currentTime
      currentLine_escaped=`echo $currentLine | sed 's,/,\\/,g'`
      sed -i "/$currentLine_escaped/d" submitList.txt
      let "nTries=$nTries+1"
      echo "$currentLine $jobid $currentTime $nTries" >> submitList.txt
      continue
    fi
  done < filesToSubmit.txt

fi
