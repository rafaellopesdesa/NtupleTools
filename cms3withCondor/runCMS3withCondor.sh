#!/bin/bash

#Give here the instructions file that you want to run
  #This should have the first line being the directory you want to run on (/store/...)
  #Subsequent lines should be the actual file names relative to that dir
  #(no way to look them up remotely, have to go to eos)
instructions=SS_samples/$1.txt

#dataset name  -- this will be saved into the final ntuple as the 'dataset' branch
DATASETNAME=$1

#State the absolute output path (in hadoop) where output should go
outputPath=/hadoop/cms/store/user/$USER/condor/SSPrivate/v07-04-08/$1/

#State the CMS3 tag you want to use
cms3tag=CMS3_V07-04-08

#Give the maximum number of events
max_nEvents="-1"

GTAG=MCRUN2_74_V9

#------HERE THERE BE DRAGONS----------

#See if already exists
here=`pwd`
nFiles=`wc -l < $instructions`
nFiles=$(( $nFiles - 1 )) 
pushd $outputPath &>/dev/null
. $here/whichMissingCondorSubmissions $nFiles > $here/whichMissing.txt
popd &>/dev/null

#Remove old tempfile
rm tempfile.txt &>/dev/null

#Make the instructions file
lineno=0
while read line
do
  lineno=$(( $lineno + 1 ))
  alreadyDone="1"
  if [ "$lineno" == "1" ]
  then 
    prefix=$line
  else  
    while read line2
    do
      if [ "$line2" == "$(( $lineno - 1 ))" ]
      then
        alreadyDone="0"
      fi
    done < whichMissing.txt
    if [ "$alreadyDone" == "0" ]; then echo "$prefix/$line" >> tempfile.txt; else echo " " >> tempfile.txt; fi
  fi
done < $instructions

#If the tempfile doesn't exist, then nothing to do, done
if [ ! -e tempfile.txt ]; then echo "Task is finished."; return; fi

#Get the current time
currentTime=`date +%s`

#Make output directory
if [ ! -d $outputPath ]
then
  mkdir -p $outputPath 
fi

#Submit it
. submit.sh tempfile.txt $currentTime $outputPath $cms3tag $max_nEvents true thisDoesntMatter $GTAG $DATASET_NAME pset_mc.py
DATASETNAME=$9
PSET=${10}

#Delete temporary stuff
#rm tempfile.txt &>/dev/null
#rm whichMissing.txt &>/dev/null
