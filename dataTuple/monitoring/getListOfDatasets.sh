#!/bin/bash

sed 's./. .g' /nfs-7/userdata/dataTuple/input.txt | awk '{print $1}' > listOfDatasets.txt #replace "/" by " " and then print out the first column
