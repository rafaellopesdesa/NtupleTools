#!/bin/bash

dataSet=$1
CMS3tag=$2

myDir=`echo $CMS3tag | cut -c 6-`
longName=`echo $dataSet | awk -F '/' '{print $2 "_" $3}'`
shortName=`echo $dataSet | awk -F '/' '{print $2}'`

if [ ! -e /hadoop/cms/store/group/snt/phys14/$longName ]
then
  mkdir /hadoop/cms/store/group/snt/phys14/$longName
  mkdir /hadoop/cms/store/group/snt/phys14/$longName/$myDir
  mv /hadoop/cms/store/user/$USER/$shortName/crab_$longName/$CMS3tag/merged/*.root /hadoop/cms/store/group/snt/phys14/$longName/$myDir
fi

root -b -l -q numEventsROOT.C\(\"$longName/$myDir\"\)
