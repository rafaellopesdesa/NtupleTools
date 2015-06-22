#!/bin/bash

FILES=$1
TIME=$2
OUTPUT_DIR=$3
OUTPUT_NAME=$4
LINENO=$5
CMS3_TAG=$6
MAX_EVENTS=$7

sed -n "$5p" $1 > tempSubmit.txt
if [ "$JOBTYPE" == "cms3" ]
then
  echo "cms3 job"
  cd cms3withCondor
  . submit.sh ../tempSubmit.txt $TIME $OUTPUT_DIR $CMS3_TAG $MAX_EVENTS false $OUTPUT_NAME 
  cd ..
elif [ "$JOBTYPE" == "user" ]
then
  echo "user job"
  cd userdir
  ./submitUserJob.sh ../tempSubmit.txt $TIME $OUTPUT_DIR $OUTPUT_NAME $MAX_EVENTS
  cd ..
else
  echo "JOBTYPE not recognized"
  exit 1
fi
rm tempSubmit.txt
