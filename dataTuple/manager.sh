#!/bin/bash

if [[ ":$PATH:" != *":$PWD:"* ]]; then
    PATH="${PATH:+"$PATH:"}$PWD"
fi

cd $PWD

#This is the manager that calls all the other pieces.  This should itself be called every N minutes.  

#Don't allow more than one instance to run
if [ "$dataTupleCronJobIsRunning" == "1" ] 
then
  echo "here1"
  return 0
else
  dataTupleCronJobIsRunning=1
  echo "here2"
fi

echo "here3"
#Make sure cms3withCondor exists
if [ ! -d cms3withCondor ] 
then
  cp -r ../cms3withCondor .
fi

cd cms3withCondor
if [[ ":$PATH:" != *":$PWD:"* ]]; then
    PATH="${PATH:+"$PATH:"}$PWD"
fi
cd ..

if [ ! -e submitList.txt ] 
then
  touch submitList.txt
fi

outputPath="/hadoop/cms/store/user/$USER/condor/dataNtupling/dataTuple"

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
    tempName=$(python getFileName.py $currentFile 2>&1)
    if [ ! -e $outputPath/$tempName ] 
    then
      echo "$currentFile"
      echo `echo $currentFile | awk ' { print $1 }'` >> filesToSubmit.txt
      continue
    else
      . checkFile.sh $outputPath/$tempName
      continue
    fi
  fi

done < notDoneList.txt

#5. Submit all the jobs that have been marked for submission
#currentTime=`date +%s`
currentTime=`date +%m%d%y_%s`
if [ -e filesToSubmit.txt ] 
then 
  while read line
  do
    currentLine=$line
    #a. Submit them
    echo "outputName=$(python getFileName.py $currentLine 2>&1)"
    outputName=$(python getFileName.py $currentLine 2>&1)
    . submitJob.sh filesToSubmit.txt $currentTime $outputPath $outputName
    #b. Verify all jobs submitted properly (??)

    #c. Update submitted list
    . getJobNumber.sh $currentTime
    . isOnSubmitList.sh $currentLine
    if [ $? != 1 ] 
    then
      . getJobNumber.sh $currentTime
      echo "currentLine:"
      echo $currentLine
      echo "$currentLine $jobid $currentTime 1" >> submitList.txt
      continue
    else
      . getJobNumber.sh $currentTime
      currentLine_escaped=`echo $currentLine | sed 's,/,\\\/,g'`
      sed -i "/$currentLine_escaped/d" submitList.txt
      let "nTries=$nTries+1"
      echo "$currentLine $jobid $currentTime $nTries" >> submitList.txt
      continue
    fi
  done < filesToSubmit.txt

fi

dataTupleCronJobIsRunning=0
