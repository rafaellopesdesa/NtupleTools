#!/bin/bash

#Give here the instructions file that you want to run
  #This should have the first line being the directory you want to run on (/store/...)
  #Subsequent lines should be the actual file names relative to that dir
  #(no way to look them up remotely, have to go to eos)
#instructions=t5qqqqww_deg_1000_315_300.txt
instructions=t5qqqqww_1200_1000_800.txt

#State the absolute output path (in hadoop) where output should go
outputPath=/hadoop/cms/store/user/$USER/condor/SSPrivate/v1.08/T5qqqqWW_1200_1000_800/

#State the CMS3 tag you want to use
cms3tag=CMS3_V07-02-08

#Give the maximum number of events
max_nEvents="-1"

#Note: the global tag is hardcoded (for now at least) to PHYS14_25_V2::All

#------HERE THERE BE DRAGONS----------

#Remove old tempfile
rm tempfile.txt &>/dev/null

#Make the instructions file
lineno=0
while read line
do
  lineno=$(( $lineno + 1 ))
  if [ "$lineno" == "1" ]
  then 
    prefix=$line
  else 
    echo "$prefix/$line" >> tempfile.txt
  fi
done < $instructions

#Get the current time
currentTime=`date +%s`

#Make output directory
if [ ! -d $outputPath ]
then
  mkdir -p $outputPath 
fi

#Submit it
. submit.sh tempfile.txt $currentTime $outputPath $cms3tag $max_nEvents true

#Delete temporary stuff
rm tempfile.txt &>/dev/null
