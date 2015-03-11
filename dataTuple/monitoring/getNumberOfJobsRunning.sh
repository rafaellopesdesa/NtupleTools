#!/bin/bash

while read line
do
  cat ../submitList.txt | grep $line | wc -l > numberOfJobsRunning_$line.txt
done < listOfDatasets.txt
