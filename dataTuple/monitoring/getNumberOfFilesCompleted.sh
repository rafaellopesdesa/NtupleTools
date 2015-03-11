#!/bin/bash

while read line
do
  cat /nfs-7/userdata/dataTuple/completedList.txt | grep $line | wc -l > numberOfFilesCompleted_$line.txt
done < listOfDatasets.txt
