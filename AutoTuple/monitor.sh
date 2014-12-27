#!/bin/bash

file=$1

#Environment
eval `scramv1 runtime -sh`
source /cvmfs/cms.cern.ch/crab3/crab.sh
export PATH=$PATH:`pwd`

#Store WHICHDONE with TRUE when job is finished (so don't keep checking on it)
WHICHDONE=()
while read p 
do
  WHICHDONE+=("false")
done < $file

if [ -e AutoTupleHQ.html ]; then rm AutoTupleHQ.html; fi

#Did the file HQ already exist?
isNew=false

#Date
dateAG=`date +%D`
timeAG=`date +%r`

#shouldContinue to go false when all jobs are done
shouldContinue=true
while [ $shouldContinue == true ] 
do
  #Header to log file, if log file does not already exist
  if [ ! -e AutoTupleHQ.html ]
  then
    isNew=true
    touch AutoTupleHQ.html
    echo '<HTML>' > AutoTupleHQ.html
    echo '<meta http-equiv="refresh" content="5">' >> AutoTupleHQ.html
    echo '<body>' >> AutoTupleHQ.html 
    echo '<H2>The AutoTuple HQ </H2>' >> AutoTupleHQ.html
    echo "Last updated at $timeAG on $dateAG <BR> <BR>" >> AutoTupleHQ.html
  else
    isNew=false
  fi

  #Read through files, call monitor script on each if not already finished
  fileNumber=0
  while read p
  do
    if [ ${WHICHDONE[$fileNumber]} == "true" ] 
    then
      let "fileNumber += 1"
      #python monitor.py "False $p"
      continue
    fi
    python monitor.py $p
    exitCode=$?
    #If job is now finished, launch post-production
    if [ $exitCode -eq 220 ] || [ $exitCode -eq 221 ]
    then 
      echo "Post processing started!" 
      WHICHDONE[$fileNumber]="true"
      python process.py $p &
    fi
    #If job is not finished, check directory to make sure
    let "fileNumber += 1"
  done < $file
  
  #Footer to log file, post on internet
  if [ $isNew == true ]
  then
    echo '</body>' >> AutoTupleHQ.html 
    echo '</HTML>' >> AutoTupleHQ.html 
  else
    dateAG=`date +%D`
    timeAG=`date +%r`
    sed -i "/Last updated at/c\Last updated at $timeAG on $dateAG <BR> <BR>" AutoTupleHQ.html
  fi
  web_autoTuple AutoTupleHQ.html &>/dev/null

  #Check if totally done, sleep and continue looping if not
  case "${WHICHDONE[@]}" in *"false"*) shouldContinue=true;; *) shouldContinue=false;; esac
  if [ $shouldContinue == true ]; then sleep 30; fi
  
done
