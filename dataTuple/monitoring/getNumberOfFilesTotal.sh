#!/bin/bash

while read line
do
  cat ../masterList.txt | grep $line | wc -l > numberOfFilesTotal_$line.txt
done < listOfDatasets.txt
