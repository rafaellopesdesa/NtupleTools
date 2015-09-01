#!/bin/bash

#User input
#Directory where the babies are stored
dir=/hadoop/cms/store/user/cgeorge/condor/SSPrivate/v07-04-08/
#Nice name for sample
name=$1
#Sparm class -- GLUINO, STOP, or OTHER
SPARM_CLASS=$2
#Sparm mass
SPARM_MASS=$3

#####----- HERE THERE BE DRAGONS --------#####

#Get condorMergingTools stuff
cp ../condorMergingTools/makeListsForMergingCrab3.py .
cp -r ../condorMergingTools/libC . 
cp -r ../condorMergingTools/libsh . 
cp -r ../condorMergingTools/submitMergeJobs.sh .
if [ ! -d cfg ]; then mkdir cfg; fi

#Get cross-section
if [ "$SPARM_CLASS" == "GLUINO" ] 
then
  temp2=`root -l -b -q go_xsec.C\($SPARM_MASS\)` 
elif [ "$SPARM_CLASS" == "STOP" ]
then
  temp2=`root -l -b -q stop_xsec.C\($SPARM_MASS\)` 
else
  echo "ERROR!  Only gluinos and stops are supported, not $SPARM_CLASS!" 
  return;
fi
xsec=`echo $temp2 | awk '{ print $NF }' | cut -c 1-7 --complement`

#Make lists
python makeListsForMergingCrab3.py -d $dir/$name -o $dir/$name/merged/ -s $name -k 1 -e 1 -x $xsec --overrideCrab 

#Submit it
. submitMergeJobs.sh cfg/${name}_cfg.sh
