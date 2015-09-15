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
  echo "Aborting. Invalid sample $1"
  exit 
fi
NEVENTS="$(./das_client.py --query="dataset=$1 $INSTANCE | grep dataset.nevents" | tail -1)"
NLUMIS="$(./das_client.py --query="dataset=$1 $INSTANCE | grep dataset.nlumis" | tail -1)"
EVT_PER_LUMI=$(echo "$NEVENTS/$NLUMIS" | bc)
LUMI_PER_JOB=$(echo "$EVT_PER_JOB/$EVT_PER_LUMI" | bc)
echo $LUMI_PER_JOB
