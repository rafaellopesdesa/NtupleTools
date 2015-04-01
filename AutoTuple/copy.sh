#!/bin/bash

dataSet=$1
CMS3tag=$2

myDir=`echo $CMS3tag | cut -c 6-`
longName=`echo $dataSet | awk -F '/' '{print $2 "_" $3}'`
shortName=`echo $dataSet | awk -F '/' '{print $2}'`

#Set username
USERNAME="$USER"
if [ "$USERNAME" == "dsklein" ]; then USERNAME="dklein"; fi
if [ "$USERNAME" == "iandyckes" ]; then USERNAME="gdyckes"; fi
if [ "$USERNAME" == "mderdzinski" ]; then USERNAME="mderdzin"; fi

#Check to see if any files other than the last have a size of < 3 GB.
nFiles_temp=`ls /hadoop/cms/store/user/$USERNAME/$shortName/crab_$longName/$CMS3tag/merged/*.root -l | wc -l`
nFiles=$(( $nFiles_temp - 1 ))
mkdir /hadoop/cms/store/user/$USERNAME/$shortName/crab_$longName/$CMS3tag/merged/temp 
echo "mv /hadoop/cms/store/user/$USERNAME/$shortName/crab_$longName/$CMS3tag/merged/merged_ntuple_$nFiles_temp.root /hadoop/cms/store/user/$USERNAME/$shortName/crab_$longName/$CMS3tag/merged/temp/"
mv /hadoop/cms/store/user/$USERNAME/$shortName/crab_$longName/$CMS3tag/merged/merged_ntuple_$nFiles_temp.root /hadoop/cms/store/user/$USERNAME/$shortName/crab_$longName/$CMS3tag/merged/temp/
find /hadoop/cms/store/user/$USERNAME/$shortName/crab_$longName/$CMS3tag/merged/*.root -type f -size -4500M -maxdepth 1 -delete 2> /dev/null
mv /hadoop/cms/store/user/$USERNAME/$shortName/crab_$longName/$CMS3tag/merged/temp/*.root /hadoop/cms/store/user/$USERNAME/$shortName/crab_$longName/$CMS3tag/merged/
rmdir /hadoop/cms/store/user/$USERNAME/$shortName/crab_$longName/$CMS3tag/merged/temp
nFiles_new=`ls /hadoop/cms/store/user/$USERNAME/$shortName/crab_$longName/$CMS3tag/merged/*.root -l | wc -l`
echo "$nFiles_new $nFiles_temp"
if [ ! "$nFiles_new" == "$nFiles_temp" ] 
then
  python process.py $3 $4 & 
else 
  #Otherwise, go ahead
  echo "Make dir /hadoop/cms/store/group/snt/phys14/$longName/$myDir"
  mkdir /hadoop/cms/store/group/snt/phys14/$longName 2> /dev/null
  mkdir /hadoop/cms/store/group/snt/phys14/$longName/$myDir 2> /dev/null
  mv /hadoop/cms/store/user/$USERNAME/$shortName/crab_$longName/$CMS3tag/merged/*.root /hadoop/cms/store/group/snt/phys14/$longName/$myDir/
  
  echo "$longName" >> crab_status_logs/copy.txt
  root -b -l -q numEventsROOT.C\(\"/hadoop/cms/store/group/snt/phys14/$longName/$myDir\"\) >> crab_status_logs/copy.txt 2>&1
fi

