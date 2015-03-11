#!/bin/bash

#This is the manager that calls all the other pieces.  This should itself be called every N minutes.  

#Don't allow more than one instance to run
if [ -e /nfs-7/userdata/dataTuple/running.pid ] 
then
  echo "An instance of manager is already running"
#  exit 1
else
  #store process info in pid file
  echo "Current time is: `date`" > /nfs-7/userdata/dataTuple/running.pid
  echo "manager running on `hostname`" >> /nfs-7/userdata/dataTuple/running.pid
  echo "PID = $$" >> /nfs-7/userdata/dataTuple/running.pid

  #also store info in log file that catches output
  echo "Current time is: `date`"
  echo "manager running on `hostname`"
  echo "PID = $$"
fi

#Set environment
export CMS_PATH=/cvmfs/cms.cern.ch
export SCRAM_ARCH=slc6_amd64_gcc481
source /cvmfs/cms.cern.ch/cmsset_default.sh
source /cvmfs/cms.cern.ch/slc6_amd64_gcc481/lcg/root/5.34.18/bin/thisroot.sh
pushd .
cd /cvmfs/cms.cern.ch/slc6_amd64_gcc481/cms/cmssw/CMSSW_7_2_0/src/
eval `scramv1 runtime -sh`
popd

if [[ ":$PATH:" != *":$PWD:"* ]]; then
    PATH="${PATH:+"$PATH:"}$PWD"
fi

cd $PWD

#Make sure cms3withCondor exists
if [ ! -d cms3withCondor ] && [ -d ../cms3withCondor ]
then
  cp -r ../cms3withCondor .
elif [ ! -d cms3withCondor ]
then
  echo "Cannot find cms3withCondor"
  exit 1
fi

#Delete files that stageout in home area
cd cms3withCondor
rm *.root 2> /dev/null 

#Set PATH
if [[ ":$PATH:" != *":$PWD:"* ]]; then
    PATH="${PATH:+"$PATH:"}$PWD"
fi
cd ..

#Create submit list
if [ -e submitList.txt ] 
then
  touch submitList.txt
fi

if [ -e /nfs-7/userdata/dataTuple/completedList.txt ] 
then
  touch /nfs-7/userdata/dataTuple/completedList.txt
fi

#Set Output Path
outputPath="/hadoop/cms/store/user/$USER/condor/dataNtupling/dataTuple"

#0. Check Proxy
. checkProxy.sh $nEmails
if [ "$?" == 1 ] 
then
  echo "Aborting -- you don't have a proxy"
  let "nEmails=$nEmails+1"
  exit 1
fi

#1. DBS query to generate masterList with files on input.txt (DONE. GenerateMasterList.sh)
echo "Populating masterList.txt with files for datasets in /nfs-7/userdata/dataTuple/input.txt"
. GenerateMasterList.sh
echo "masterList.txt written"

#2. Diff between masterList and completedList to make notDoneList. (DONE. makeNotDoneList.sh)
echo "Getting list of files that are on masterList but not on completedList"
. makeNotDoneList.sh
echo "notDoneList.txt written"

#3. condor_q makes runningList and heldList. Jobs on the heldList are killed. (DONE. checkStatus.sh)
echo "Using condor_q to get see which jobs are running"
. checkStatus.sh
echo "runningList.txt and heldList.txt written"

#4. Cycle through files on notDoneList. (DONE)
echo "Cycling through notDoneList.txt"
rm filesToSubmit.txt 2> /dev/null
while read line
do
  currentFile=$line

  #a.  See if job is on failure list.  If yes, continue
  echo "step 4a"
  . isOnFailureList.sh $currentFile
  if [ "$?" -eq "1" ]; then continue; fi
 
  #b. See if each job is on submitList. If no, mark the job for submission and on to step 5. (DONE)
  echo "step 4b"
  . isOnSubmitList.sh $currentFile
  isOnSubmitList=$?
  echo "current file: $currentFile"
  if [ $isOnSubmitList != 1 ] 
  then
    echo "Not on submit list, submitting"
    echo $currentFile >> filesToSubmit.txt
    continue
  fi

  #c. Otherwise, it's on the submitList. Get the jobID from there and see if the job is running.
  echo "step 4c"
  echo "job id: $jobid"
  condor_q $jobid > temp_isRunning.txt
  sed -i '1,4d' temp_isRunning.txt
  if [ -s temp_isRunning.txt ]; then isRunning=true; else isRunning=false; fi
  echo "isRunning: $isRunning"
  rm temp_isRunning.txt


  #d. If job is on run list, check time. If has been running for more than 24 hours, kill it, mark for submission, and on to step 5.
  echo "step 4d"
  if [ $isRunning == true ] 
  then
    echo "starttime: $starttime"
    tooMuchTime=$(python checkTime.py $starttime 2>&1)
    if [ $tooMuchTime == true ]
    then
      condor_rm $jobid
      echo "too much time, submitting"
      echo $currentFile >> filesToSubmit.txt
      continue
    fi
  fi

  #e. If not on run list, check if the output file is present and valid. If not present and valid, mark for submission and on to step 5.
  echo "step 4e"
  if [ $isRunning == false ] 
  then
    tempName=$(python getFileName.py $currentFile 2>&1)
    #Check for file in hadoop
    #If file not in hadoop, allow 20 mins for transfer.
    #If file is in hadoop, check that it is valid
    if [ ! -e $outputPath/$tempName ] 
    then
      #See when job finished
      currentFile_escaped=`echo $currentFile | sed 's,/,\\\/,g'`
      lineNo=`sed -n /$currentFile_escaped/= submitList.txt`
      whenFinish=`awk -v var="$lineNo" 'NR==var {print $NF}' submitList.txt`
      timeSinceEpoch=`date +%s`
      #add finish time to submit list
      if [ "$whenFinish" == "0" ]
      then
      echo "lineNo: $lineNo timeSinceEpoch $timeSinceEpoch"
      echo `sed -n ${lineNo} submitList.txt | head 1`
      sed -i "${lineNo}s/0$/$timeSinceEpoch/g" submitList.txt 
      #If it's been less than 20 minutes, don't resubmit
      #This allows for delay in transfer of output
      elif [ `echo $(( ($timeSinceEpoch - $whenFinish) < 1200))` == 1 ]
      then
        echo "Job finished within the last 20 mins for $currentFile but output is missing. Waiting."
      else
        echo "No job running in the last 20 mins and no output file for $currentFile"
        echo "Submitting a new job"
        echo `echo $currentFile | awk ' { print $1 }'` >> filesToSubmit.txt
      fi
    else
      . checkFile.sh $outputPath/$tempName $currentFile
      continue
    fi
  fi

done < notDoneList.txt

#5. Submit all the jobs that have been marked for submission
currentTime=`date +%s`
lineno=0
if [ -e filesToSubmit.txt ] 
then 
  while read line
  do
  let "lineno=$lineno+1"
    currentLine=$line
 
    #a. Check number of times submitted
    echo "step 5a"
    . isOnSubmitList.sh $currentLine
    isOnSubmitList=$?
    if [ "$isOnSubmitList" -eq "1"  ] 
    then
      echo "nTries: $nTries" 
      if [ "$nTries" -gt "10" ] && [ "$nTries" -lt "30" ]
      then
        let "nTries=$nTries+1"
        continue
      elif [ "$nTries" -eq "35" ] 
      then
        echo "DataTupleError!  File $currentLine has failed many times." | /bin/mail -r "george@physics.ucsb.edu" -s "[dataTuple] error report" "george@physics.ucsb.edu, jgran@physics.ucsb.edu" 
        $currentLine > failure.txt
        continue
      fi
    fi

    #5b. Submit them
    echo "step 5b"
    echo "outputName=$(python getFileName.py $currentLine 2>&1)"
    outputName=$(python getFileName.py $currentLine 2>&1)
    . submitJob.sh filesToSubmit.txt $currentTime $outputPath $outputName $lineno

    #c. Update submitted list
    echo "step 5c"
    . getJobNumber.sh $currentTime
    . isOnSubmitList.sh $currentLine
    if [ $? != 1 ] 
    then
      . getJobNumber.sh $currentTime
      echo "currentLine:"
      echo $currentLine
      echo "$currentLine $jobid $currentTime 1 0" >> submitList.txt
      continue
    else
      . getJobNumber.sh $currentTime
      currentLine_escaped=`echo $currentLine | sed 's,/,\\\/,g'`
      sed -i "/$currentLine_escaped/d" submitList.txt
      let "nTries=$nTries+1"
      echo "$currentLine $jobid $currentTime $nTries 0" >> submitList.txt
      continue
    fi
  done < filesToSubmit.txt

fi

. monitor.sh

rm /nfs-7/userdata/dataTuple/running.pid
