#!/bin/bash

echo "Running monitor.sh"

OUT=/nfs-7/userdata/dataTuple/dataTupleMonitor.txt

sed 's./. .g' /nfs-7/userdata/dataTuple/input.txt | awk '{print $1}' > listOfDatasets.txt #replace "/" by " " and then print out the first column

echo "Last updated: `date`" > $OUT
echo "" >> $OUT

echo "List of datasets being processed:" >> $OUT
cat listOfDatasets.txt >> $OUT

echo "" >> $OUT

while read line
do
  DATASET=$line
  NTOTAL=`cat masterList.txt | grep $line | wc -l`
  NCOMPLETED=`cat /nfs-7/userdata/dataTuple/completedList.txt | grep $line | wc -l`
  NJOBS=`cat submitList.txt | grep $line | wc -l`
  echo "Dataset: $DATASET" >> $OUT
  echo "Number of files in dataset: $NTOTAL" >> $OUT
  echo "Number of files processed: $NCOMPLETED" >> $OUT
  echo "Number of jobs running: $NJOBS" >> $OUT
  echo "" >> $OUT
done < listOfDatasets.txt

rm listOfDatasets.txt
