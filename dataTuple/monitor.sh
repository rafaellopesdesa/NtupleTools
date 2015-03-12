#!/bin/bash

echo "Running monitor.sh"

OUT=/nfs-7/userdata/dataTuple/dataTupleMonitor.txt

sed 's./. .g' /nfs-7/userdata/dataTuple/input.txt | awk '{print $1}' > listOfDatasets.txt #replace "/" by " " and then print out the first column

echo "Last updated: `date`" > $OUT
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
  NCOMPLETED=`cat /nfs-7/userdata/dataTuple/completedList.txt | grep $line | wc -l`
  if [ -e runningList.txt ]; then NJOBSRUNNING=`cat runningList.txt | grep $line | wc -l`; fi
  if [ -e idleList.txt ]; then NJOBSIDLE=`cat idleList.txt | grep $line | wc -l`; fi
  if [ -e heldList.txt ]; then NJOBSHELD=`cat heldList.txt | grep $line | wc -l`; fi
  echo "Dataset: $DATASET" >> $OUT
  echo "Number of files in dataset: $NTOTAL" >> $OUT
  echo "Number of files processed: $NCOMPLETED" >> $OUT
  echo "Number of jobs running: $NJOBSRUNNING" >> $OUT
  echo "Number of jobs idle: $NJOBSIDLE" >> $OUT
  echo "Number of jobs held: $NJOBSHELD" >> $OUT
  echo "" >> $OUT
done < listOfDatasets.txt

rm listOfDatasets.txt
