#/bin/bash

if [ ! -d $BASEPATH ]
then
  echo "BASEPATH in checkFile.sh does not exist!"
fi

if [ "$JOBTYPE" == "cms3" ]
then
  ./sweepRoot -o Events -t Events $2 > validFileOutput.txt
elif [ "$JOBTYPE" == "user" ]
then
  ./sweepRoot -o Events $2 > validFileOutput.txt
else
  echo "JOBTYPE not recognized"
  exit 1
fi

isGood=0

if [ ! -d $BASEPATH/fileLists ] 
then
  mkdir -p $BASEPATH/fileLists
fi

readarray -t results < validFileOutput.txt
for i in "${results[@]}"
do
  if [ "$i" == "SUMMARY: 0 bad, 1 good" ]; then
    echo $2 >> $BASEPATH/fileLists/`date +%F`.txt
    echo $3 >> $BASEPATH/completedList.txt
    filename_escaped=`echo $3 | sed 's,/,\\\/,g'`
    sed -i "/$filename_escaped/d" submitList.txt
    if [ -e failureList.txt ]; then
      sed -i "/$filename_escaped/d" failureList.txt
    fi
    isGood=1
    break;
  elif [ "$i" == "SUMMARY: 1 bad, 0 good" ]; then
    rm $2
    echo $3 >> filesToSubmit.txt
    break;
  fi
done

rm validFileOutput.txt

currentNumber=0
currentSize=0
newFileNevents=0

#If the file is good, add it to list for post-processing
if [ "$isGood" == "1" ] 
then
  taskName=`echo $3 | tr '/' ' ' |  awk '{print $3"_"$4"_"$5"_"$6}'`
  if [ ! -d $BASEPATH/mergedLists/$taskName ]; then mkdir -p $BASEPATH/mergedLists/$taskName; fi
  if [ ! -e $BASEPATH/mergedLists/$taskName/status.txt ]
  then
    echo "currently filling: 0" >> $BASEPATH/mergedLists/$taskName/status.txt
    echo "current size (bytes): 0" >> $BASEPATH/mergedLists/$taskName/status.txt
    echo "current nEvents: 0" >> $BASEPATH/mergedLists/$taskName/status.txt
  fi
  mergedFileNumber=`less $BASEPATH/mergedLists/$taskName/status.txt | head -1 | awk '{print $3}'`
  echo $2 >> $BASEPATH/mergedLists/$taskName/merged_list_$mergedFileNumber.txt 
  currentSize=`less $BASEPATH/mergedLists/$taskName/status.txt | head -2 | tail -1 | awk '{print $4}'`
  currentNumber=`less $BASEPATH/mergedLists/$taskName/status.txt | head -3 | tail -1 | awk '{print $3}'`
  newFileSize=`ls -l $2 | awk '{print $5}'`
  newTotalSize=$(( $newFileSize + $currentSize ))
  newFileNevents=`root -b -q getNevents.C\(\"$2\"\) &> blah.txt; less blah.txt | tail -1 | cut -c 1-5 --complement ; rm blah.txt`
  newTotalNevents=$(( $currentNumber + $newFileNevents ))
  sed -i "s/current\ size\ (bytes).*/current size (bytes): $newTotalSize/" $BASEPATH/mergedLists/$taskName/status.txt
  sed -i "s/current\ nEvents.*/current nEvents: $newTotalNevents/" $BASEPATH/mergedLists/$taskName/status.txt

  #If we now have enough to run post-processing, prepare the files 
  if [ "$newTotalSize" -gt "300000000" ]
  then
    #(a) Reset counters for this script
    sed -i "s/currently filling.*/currently filling: $(( $mergedFileNumber + 1 ))/" $BASEPATH/mergedLists/$taskName/status.txt
    sed -i "s/current\ size\ (bytes).*/current size (bytes): 0/" $BASEPATH/mergedLists/$taskName/status.txt
    sed -i "s/current\ nEvents.*/current nEvents: 0/" $BASEPATH/mergedLists/$taskName/status.txt
    #(b) Write the meta data file
    echo "n: $newTotalNevents" >> $BASEPATH/mergedLists/$taskName/metaData_$mergedFileNumber.txt
    echo "k: 1" >> $BASEPATH/mergedLists/$taskName/metaData_$mergedFileNumber.txt
    echo "f: 1" >> $BASEPATH/mergedLists/$taskName/metaData_$mergedFileNumber.txt
    echo "x: 1" >> $BASEPATH/mergedLists/$taskName/metaData_$mergedFileNumber.txt
    echo "file: merged_list_$mergedFileNumber.txt" >> $BASEPATH/mergedLists/$taskName/metaData_$mergedFileNumber.txt
    #(c) Submit it
    . submitPPJob.sh $taskName $mergedFileNumber
  fi

fi

isGood=0
