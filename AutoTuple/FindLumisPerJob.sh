#!/bin/bash

EVT_PER_JOB=30000
INSTANCE="" # needed for USER published datasets in phys03
if [[ $1 == */USER ]]; then INSTANCE="instance=prod/phys03"; fi
STATUS="$(./das_client.py --query="dataset=$1 $INSTANCE | grep dataset.status" | tail -1)" 
if [ "$STATUS" == "[]" ]
then
  echo "Aborting. Not on DAS $1"
  exit 
fi
if [ "$STATUS" == "INVALID" ]
then
  read -p "Dataset $1 is invalid.  Do you want to crab it anyway? (y/n)" -n 1 -r
  echo 
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
    echo "You did not type y.  Aborting."
    exit
  else
    echo "FILEBASED"
    exit
  fi
fi
NEVENTS="$(./das_client.py --query="dataset=$1 $INSTANCE | grep dataset.nevents" | tail -1)"
echo $NEVENTS
NLUMIS="$(./das_client.py --query="dataset=$1 $INSTANCE | grep dataset.nlumis" | tail -1)"
echo $NLUMIS
EVT_PER_LUMI=$(echo "$NEVENTS/$NLUMIS" | bc)
LUMI_PER_JOB=$(echo "$EVT_PER_JOB/$EVT_PER_LUMI" | bc)
MAXEVENTS="$(./das_client.py --query="file dataset=$1 $INSTANCE | grep file.nevents" --limit=0 | xargs ./maxAG.sh)"
if [ "$MAXEVENTS" -lt "70000" ] && [ "$MAXEVENTS" -gt "15000" ]
then
  echo "FILEBASED"
else
  echo $LUMI_PER_JOB
fi
