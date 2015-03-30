#!/bin/bash

#To do:
  #Redo flag 
  #Submit merge jobs to be a sed command

#File
file=$1

#Get Tag, Global Tag
lineno=0
while read line
do
  let "lineno=$lineno+1"
  if [ "$lineno" == "1" ]; then gtag=$line
  elif [ "$lineno" == "2" ]; then tag=$line
  fi
done < $file

#Environment
eval `scramv1 runtime -sh`
source /cvmfs/cms.cern.ch/crab3/crab.sh
export PATH=$PATH:`pwd`

#Make sure public_html directory exists
if [ ! -d ~/$USERNAME/public_html ] 
then
  mkdir ~/$USERNAME/public_html
fi

#Pirate picture
cp crabPic.png /home/users/$USER/public_html/crabPic.png &>/dev/null
chmod a+r ~/public_html/crabPic.png

#Store WHICHDONE with TRUE when job is finished (so don't keep checking on it)
WHICHDONE=()
while read p 
do
  WHICHDONE+=("false")
done < $file
WHICHDONE[0]="true"
WHICHDONE[1]="true"

#Remove HTML file
if [ -e AutoTupleHQ.html ]; then rm AutoTupleHQ.html; fi

#Make directory for crab status logs
if [ ! -d crab_status_logs ]; then mkdir crab_status_logs; fi

#Date
dateAG=`date +%D`
timeAG=`date +%r`

#shouldContinue to go false when all jobs are done
shouldContinue="true"

#main loop
while [ "$shouldContinue" == "true" ] 
do
  #Delete the existing one 
  if [ -e AutoTupleHQ.html ]; then rm AutoTupleHQ.html; fi

  #Output the header stuff
  touch AutoTupleHQ.html
  echo '<HTML>' > AutoTupleHQ.html
  echo '<meta http-equiv="refresh" content="15">' >> AutoTupleHQ.html
  echo '<body>' >> AutoTupleHQ.html 
  echo '<img src="crabPic.png" width="50%" height="50%"> <BR>' >> AutoTupleHQ.html
  echo "Last updated at $timeAG on $dateAG <BR> <BR>" >> AutoTupleHQ.html

  #Loop over files and do status check 
  fileNumber=0
  while read line
  do
    #Skip the first two lines
    if [ $fileNumber \< 2 ]
    then 
      let "fileNumber += 1"
      continue 
    fi

    #skip if already finished
    if [ ${WHICHDONE[$fileNumber]} == "true" ] 
    then
      let "fileNumber += 1"
      continue
    fi

    #Otherwise, need to check.  Get the variables:
    filename=`echo $line | awk '{print $1}'`
    xsec=`echo $line | awk '{print $2}'`
    kfact=`echo $line | awk '{print $3}'`
    isData=`echo $line | awk '{print $4}'`

    #Calculate directory names
    temp=`echo ${filename//\//_} | cut -c 2-`
    crab_filename=${temp%_*}
    status_filename="crab_status_logs/${crab_filename}_log.txt"

    #Output name with hyperlink to log
    echo "  " >> AutoTupleHQ.html
    echo "<A HREF=\"http://uaf-7.t2.ucsd.edu/~$USER/${crab_filename}_log.txt\"> ${crab_filename}</A><BR>" >> AutoTupleHQ.html

    #Do the check, upload result
    crab status crab_$crab_filename --long > $status_filename
    cp $status_filename /home/users/$USER/public_html/${crab_filename}_log.txt &>/dev/null

    #If status is done, we're done
    temp=`grep -r "Task status" $status_filename | grep "COMPLETED"`
    if [ "$temp" == "" ]; then isDone="0"; else isDone="1"; fi
    if [ "$isDone" == "1" ]
    then
      echo '<font color="blue"> &nbsp; &nbsp; <b> Task is finished!! <font color="black"></b><BR><BR>' >> AutoTupleHQ.html
      WHICHDONE[$fileNumber]="true"
      continue
    fi

    #If status is queued, we're done
    grep -r "QUEUED" $status_filename >/dev/null
    isQueued="$?"
    if [ "$isQueued" == "0" ]
    then
      echo '<font color="blue"> &nbsp; &nbsp; <b> Task is Queued!! <font color="black"></b><BR><BR>' >> AutoTupleHQ.html
      continue
    fi

    #Otherwise, get distribution
    nUnsubmitted=`grep -r "unsubmitted" $status_filename | grep "%" | awk '{print $NF}' | sed 's/(//' | sed 's/)//' | sed 's/\//\ /' | awk '{print $1}'`
    nIdle=`grep -r "idle" $status_filename | grep "%" | awk '{print $NF}' | sed 's/(//' | sed 's/)//' | sed 's/\//\ /' | awk '{print $1}'`
    nRunning=`grep -r "running" $status_filename | grep "%" | awk '{print $NF}' | sed 's/(//' | sed 's/)//' | sed 's/\//\ /' | awk '{print $1}'`
    nFailed=`grep -r "failed" $status_filename | grep "%" | awk '{print $NF}' | sed 's/(//' | sed 's/)//' | sed 's/\//\ /' | awk '{print $1}'`
    nTransferring=`grep -r "transferring" $status_filename | grep "%" | awk '{print $NF}' | sed 's/(//' | sed 's/)//' | sed 's/\//\ /' | awk '{print $1}'`
    nTransferred=`grep -r "transferred" $status_filename | grep "%" | awk '{print $NF}' | sed 's/(//' | sed 's/)//' | sed 's/\//\ /' | awk '{print $1}'`
    nCooloff=`grep -r "cooloff" $status_filename | grep "%" | awk '{print $NF}' | sed 's/(//' | sed 's/)//' | sed 's/\//\ /' | awk '{print $1}'`
    nFinished=`grep -r "finished" $status_filename | grep "%" | awk '{print $NF}' | sed 's/(//' | sed 's/)//' | sed 's/\//\ /' | awk '{print $1}'`
    denominator=`grep -r "%" $status_filename | grep ")" | | grep "Details:" | awk '{print $NF}' | sed 's/(//' | sed 's/)//' | sed 's/\//\ /' | awk '{print $2}'`

    #If any are empty, set them to 0
    if [ "$nUnsubmitted"  == "" ]; then nUnsubmitted="0"; fi
    if [ "$nIdle"         == "" ]; then nIdle="0"; fi
    if [ "$nRunning"      == "" ]; then nRunning="0"; fi
    if [ "$nFailed"       == "" ]; then nFailed="0"; fi
    if [ "$nTransferring" == "" ]; then nTransferring="0"; fi
    if [ "$nTransferred"  == "" ]; then nTransferred="0"; fi
    if [ "$nCooloff"      == "" ]; then nCooloff="0"; fi
    if [ "$nFinished"     == "" ]; then nFinished="0"; fi
    if [ "$denominator"   == "" ]; then denominator="0"; fi
  
    #Print the distribution
    echo "&nbsp; &nbsp; unsubmitted: $nUnsubmitted/$denominator <BR>" >> AutoTupleHQ.html
    echo "&nbsp; &nbsp; idle: $nIdle/$denominator <BR>" >> AutoTupleHQ.html
    echo "&nbsp; &nbsp; running: $nRunning/$denominator <BR>" >> AutoTupleHQ.html
    if [ "$nFailed" == "0" ] 
    then
      echo "&nbsp; &nbsp; failed: $nFailed/$denominator <BR>" >> AutoTupleHQ.html
    else
      echo "<font color="red"> &nbsp; &nbsp; <b> failed: $nFailed/$denominator <font color="black"> </b> <BR>" >> AutoTupleHQ.html
    fi
    echo "&nbsp; &nbsp; transferring: $nTransferring/$denominator <BR>" >> AutoTupleHQ.html
    echo "&nbsp; &nbsp; transferred: $nTransferred/$denominator <BR>" >> AutoTupleHQ.html
    echo "&nbsp; &nbsp; cooloff: $nCooloff/$denominator <BR>" >> AutoTupleHQ.html
    echo "&nbsp; &nbsp; <b> finished: $nFinished/$denominator </b> <BR><BR>" >> AutoTupleHQ.html
    
  done < $file 

  #Footer for HTML file
  echo '</body>' >> AutoTupleHQ.html 
  echo '</HTML>' >> AutoTupleHQ.html 

  #Upload HTML file
  cp AutoTupleHQ.html /home/users/$USER/public_html/AutoTupleHQ.html &>/dev/null

  #Check if totally done, sleep and continue looping if not
  case "${WHICHDONE[@]}" in *"false"*) shouldContinue=true;; *) shouldContinue=false;; esac
  if [ $shouldContinue == true ]; then sleep 30; fi
  
done
