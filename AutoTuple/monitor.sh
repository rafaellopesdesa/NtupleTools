#!/bin/bash

#Check for instructions file
if [ $# -eq 0 ] 
  then 
  echo "No arguments, mate!  Need the instructions file....." 
  exit 
fi

#Print status to screen
echo " " 
echo " " 
echo "All quiet, cap'n!  Monitoring has begun....."
echo "Yer can see yer progrress at uaf-7.t2.ucsd.edu/~$USER/AutoTupleHQ.html"

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
WHICHDONE[0]="done"
WHICHDONE[1]="done"

#Remove HTML file
if [ -e AutoTupleHQ.html ]; then rm AutoTupleHQ.html; fi

#Make directory for crab status logs
if [ ! -d crab_status_logs ]; then mkdir crab_status_logs; fi

#shouldContinue to go false when all jobs are done
shouldContinue="true"

#remove old post-processing logs
rm crab_status_logs/pp.txt 2>/dev/null 
rm crab_status_logs/copy.txt 2>/dev/null 

#variable so we do one last loop
last_loop=0

#main loop
while [ "$last_loop" -lt "2"  ] 
do
  #Delete the existing one 
  if [ -e AutoTupleHQ.html ]; then rm AutoTupleHQ.html; fi

  #Date & Time
  dateAG=`date +%D`
  timeAG=`date +%r`

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

    #Get the variables:
    filename=`echo $line | awk '{print $1}'`
    xsec=`echo $line | awk '{print $2}'`
    kfact=`echo $line | awk '{print $3}'`
    isData=`echo $line | awk '{print $4}'`

    #Calculate directory names
    temp=`echo ${filename//\//_} | cut -c 2-`
    crab_filename=${temp%_*}
    status_filename="crab_status_logs/${crab_filename}_log.txt"

    #skip if already finished
    if [ ${WHICHDONE[$fileNumber]} == "done" ] 
    then
      if [ -e crab_status_logs/copy.txt ]
      then
        temp=`echo $line | awk '{print $1}'`
        temp2=`echo ${temp//\//_} | cut -c 2-`
        filename=${temp2%_*}
        nIn=`grep -r "$filename" crab_status_logs/pp.txt | tail -1 | awk '{print $3}'`
        grep -r "$filename" crab_status_logs/copy.txt | grep "trying to recover" 2> /dev/null
        copyProblem=$?
        nOut=`grep -r "$filename" crab_status_logs/copy.txt | grep "nEntries" | tail -1 | awk '{print $NF}'`
        let "fileNumber += 1"
        echo "  " >> AutoTupleHQ.html
        if [ "$copyProblem" != "0" ] 
        then
          echo "<A HREF=\"http://uaf-7.t2.ucsd.edu/~$USER/${crab_filename}_log.txt\"> ${crab_filename}</A><BR>" >> AutoTupleHQ.html
          echo "<font color=\"blue\"> &nbsp; &nbsp; <b> This task be finished!!!! nEventsIn: $nIn nEventsOut: $nOut <font color=\"black\"></b><BR><BR>" >> AutoTupleHQ.html
          continue
        elif [ "$copyProblem" == "0" ] 
        then
          echo "<A HREF=\"http://uaf-7.t2.ucsd.edu/~$USER/${crab_filename}_log.txt\"> ${crab_filename}</A><BR>" >> AutoTupleHQ.html
          echo "<font color=\"red\"> &nbsp; &nbsp; <b> Ahoy, matey!! This task be finished, but there may be some problem with the output.  I suggest taking a look at the output in the hadoop snt directory!   nEventsIn: $nIn.  <font color=\"black\"></b><BR><BR>" >> AutoTupleHQ.html
          continue
        fi
      else
        WHICHDONE[$fileNumber]="true"
      fi
    elif [ ${WHICHDONE[$fileNumber]} == "notPP" ] 
    then
      let "fileNumber += 1"
      echo "  " >> AutoTupleHQ.html
      echo "<A HREF=\"http://uaf-7.t2.ucsd.edu/~$USER/${crab_filename}_log.txt\"> ${crab_filename}</A><BR>" >> AutoTupleHQ.html
        echo '<font color="blue"> &nbsp; &nbsp; <b> This task be finished!!!! Note well, matey, that we did not post-process, because the dirrrectory already existed on hadoop!!  <font color="black"></b><BR><BR>' >> AutoTupleHQ.html
      continue
    fi

    #if crab has finished but post-processing has not, check on post-processing
    if [ ${WHICHDONE[$fileNumber]} == "true" ] 
    then
      #Print header
      echo "  " >> AutoTupleHQ.html
      echo "<A HREF=\"http://uaf-7.t2.ucsd.edu/~$USER/${crab_filename}_log.txt\"> ${crab_filename}</A><BR>" >> AutoTupleHQ.html
       
      #If there is no pp log, print status message
      if [ ! -e crab_status_logs/pp.txt ]
      then
        echo '<font color="blue"> &nbsp; &nbsp; <b> Post-Processing is underway!  No status available yet....  <font color="black"></b><BR><BR>' >> AutoTupleHQ.html
      #Otherwise, get filename and check log to see if there's any trace of it
      else
        temp=`echo $line | awk '{print $1}'`
        temp2=`echo ${temp//\//_} | cut -c 2-`
        filename=${temp2%_*}
        grep -r "$filename" crab_status_logs/pp.txt > /dev/null
        foundIt="$?"
    
        #Either way, print status message
        if [ "$foundIt" != "0" ] 
        then
          echo '<font color="blue"> &nbsp; &nbsp; <b> Post-Processing is underway!  No status available yet....  <font color="black"></b><BR><BR>' >> AutoTupleHQ.html
        else
          isDonePP=`grep -r "$filename" crab_status_logs/pp.txt | tail -1 | awk '{print $2}'`
          nEntriesIn=`grep -r "$filename" crab_status_logs/pp.txt | tail -1 | awk '{print $3}'`
          if [ "$isDonePP" == "done" ] 
          then
            echo "<font color=\"blue\"> &nbsp; &nbsp; <b> Post-Processing is finished!  nEventsIn: $nEntriesIn  <font color=\"black\"></b><BR><BR>" >> AutoTupleHQ.html
            WHICHDONE[$fileNumber]="done"
          elif [ "$isDonePP" == "alreadyThere" ] 
          then
            echo "<font color=\"blue\"> &nbsp; &nbsp; <b> Not going to postprocess, already exists on hadoop....  <font color=\"black\"></b><BR><BR>" >> AutoTupleHQ.html
            WHICHDONE[$fileNumber]="notPP"
          else
            nEntriesIn=`grep -r "$filename" crab_status_logs/pp.txt | tail -1 | awk '{print $2}'`
            nFinished=`grep -r "$filename" crab_status_logs/pp.txt | tail -1 | awk '{print $3}'`
            nTotal=`grep -r "$filename" crab_status_logs/pp.txt | tail -1 |  awk '{print $4}'`
            echo "<font color=\"blue\"> &nbsp; &nbsp; <b> Post-Processing is underway!  nEventsIn: $nEntriesIn.  Current progress: $nFinished/$nTotal  <font color=\"black\"></b><BR><BR>" >> AutoTupleHQ.html
          fi
        fi
      fi
 
      #Increment file nmuber, continue
      let "fileNumber += 1"
      continue
    fi

    #Output name with hyperlink to log
    echo "  " >> AutoTupleHQ.html
    echo "<A HREF=\"http://uaf-7.t2.ucsd.edu/~$USER/${crab_filename}_log.txt\"> ${crab_filename}</A><BR>" >> AutoTupleHQ.html

    #Do the check, upload result
    crab status crab_$crab_filename --long > $status_filename
    cp $status_filename /home/users/$USER/public_html/${crab_filename}_log.txt >/dev/null

    #If status is done, we're done
    temp=`grep -r "Task status" $status_filename | grep "COMPLETED"`
    if [ "$temp" == "" ]; then isDone="0"; else isDone="1"; fi
    if [ "$isDone" == "1" ]
    then
      echo '<font color="blue"> &nbsp; &nbsp; <b> Ready for Post-Processing!!  <font color="black"></b><BR><BR>' >> AutoTupleHQ.html
      WHICHDONE[$fileNumber]="true"
      python process.py $file $fileNumber &
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
    denominator=`grep -r "%" $status_filename | grep ")" | grep "Details:" | awk '{print $NF}' | sed 's/(//' | sed 's/)//' | sed 's/\//\ /' | awk '{print $2}'`

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

    #If less than 25% of the jobs have failed, force resubmission
    if [ "$denominator" -gt "$(( 4*$nFailed ))" ] && [ "$nFailed" -gt "0" ] 
    then
      crab resubmit crab_$crab_filename
    fi

    #Increase counter
    let "fileNumber += 1"
    
  done < $file 

  #Footer for HTML file
  echo '</body>' >> AutoTupleHQ.html 
  echo '</HTML>' >> AutoTupleHQ.html 

  #Upload HTML file
  cp AutoTupleHQ.html /home/users/$USER/public_html/AutoTupleHQ.html &>/dev/null

  #Check if totally done, sleep and continue looping if not
  case "${WHICHDONE[@]}" in *"false"*) shouldContinue=true;; *) shouldContinue=false;; esac
  case "${WHICHDONE[@]}" in *"true"*) shouldContinue=true;; *) shouldContinue=false;; esac
  if [ $shouldContinue == true ]; then sleep 30; fi
  if [ $shouldContinue == false ]; then let "last_loop=$last_loop+1"; sleep 5; fi
  
done
