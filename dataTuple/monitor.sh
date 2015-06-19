#!/bin/bash

echo "Running monitor.sh"

if [ $# -eq 0 ] 
  then 
    echo "No BASEPATH specified in monitor.sh!"
    exit
  else
    BASEPATH=$1
fi

if [ ! -d $BASEPATH ]
then
  echo "BASEPATH monitor.sh does not exist!"
fi

OUT=$BASEPATH/dataTupleMonitor.txt

sed 's./. .g' $BASEPATH/input.txt | awk '{print $1}' > listOfDatasets.txt #replace "/" by " " and then print out the first column

echo "Last updated: `date`" > $OUT
echo "" >> $OUT

echo "User running the cron job: $USER" >> $OUT
echo "" >> $OUT

echo "List of datasets being processed:" >> $OUT
cat listOfDatasets.txt >> $OUT

echo "" >> $OUT

NJOBSRUNNING=0
NJOBSIDLE=0
NJOBSHELD=0

while read line
do
  DATASET=$line
  NTOTAL=`cat masterList.txt | grep $line | wc -l`
  NCOMPLETED=`cat $BASEPATH/completedList.txt | grep $line | wc -l`
  if [ -e runningList.txt ]; then NJOBSRUNNING=`cat runningList.txt | grep $line | wc -l`; fi
  if [ -e idleList.txt ]; then NJOBSIDLE=`cat idleList.txt | grep $line | wc -l`; fi
  if [ -e heldList.txt ]; then NJOBSHELD=`cat heldList.txt | grep $line | wc -l`; fi
  echo "Dataset: $DATASET" >> $OUT
  echo "Number of files in dataset: $NTOTAL" >> $OUT
  echo "Number of files processed: $NCOMPLETED" >> $OUT
  echo "Number of jobs running: $NJOBSRUNNING" >> $OUT
  echo "Number of jobs idle: $NJOBSIDLE" >> $OUT
  echo "" >> $OUT
done < listOfDatasets.txt

rm listOfDatasets.txt
