#!/bin/bash

dataSet=$1
CMS3tag=$2
dateTime=$3

thedir="run2"

myDir=`echo $CMS3tag | cut -c 6-`
longName=`echo $dataSet | awk -F '/' '{print $2 "_" $3}'`
shortName=`echo $dataSet | awk -F '/' '{print $2}'`

#Set username
USERNAME="$USER"
if [ "$USERNAME" == "dsklein" ]; then USERNAME="dklein"; fi
if [ "$USERNAME" == "iandyckes" ]; then USERNAME="gdyckes"; fi
if [ "$USERNAME" == "mderdzinski" ]; then USERNAME="mderdzin"; fi

#check CMS3
nRedo=`grep -r "Too few merged events\!" copy_log_WJetsToLNu_HT-600toInf_Tune4C_13TeV-madgraph-tauola.log | awk '{print $5}'`
rooot -b -q checkCMS3.C\(\"/hadoop/cms/store/group/snt/$thedir/WJetsToLNu_HT-600toInf_Tune4C_13TeV-madgraph-tauola_Phys14DR-PU20bx25_PHYS14_25_V1-v1/V07-02-08\",\"/hadoop/cms/store/user/$USERNAME/$shortName/crab_$longName/$dateTime/0000/\",0,0\) > copy_log_$shortName.log
nProblems=`grep -r "Problems found:" copy_log_$shortName.log | awk '{print $3}'`
grep -r  "Too few merged events!" copy_log_$shortName.log &>/dev/null
mergingProblems=$?

if [ "$nProblems" == "0" ]
then
  #Do the copy
  mkdir /hadoop/cms/store/group/snt/$thedir/$longName 2> /dev/null
  mkdir /hadoop/cms/store/group/snt/$thedir/$longName/$myDir 2> /dev/null
  #mv /hadoop/cms/store/user/$USERNAME/$shortName/crab_$longName/$CMS3tag/merged/*.root /hadoop/cms/store/group/snt/$thedir/$longName/$myDir/
  echo "mv /hadoop/cms/store/user/$USERNAME/$shortName/crab_$longName/$CMS3tag/merged/*.root /hadoop/cms/store/group/snt/$thedir/$longName/$myDir/"
  echo "$longName" >> crab_status_logs/copy.txt
  root -b -l -q numEventsROOT.C\(\"/hadoop/cms/store/group/snt/$thedir/$longName/$myDir\"\) >> crab_status_logs/copy.txt 2>&1
elif [ "$nProblems" == "1" ] && [ "$mergingProblems" == "0" ]
then
  #Resubmit merge jobs
  if [ "$nRedo" == "" ]; then nRedo2=0; else nRedo2=$(( $nRedo + 1 )); fi
  sed -i "s/Too few merged events! $nRedo/Too few merged events! $nRedo2/" copy_log_WJetsToLNu_HT-600toInf_Tune4C_13TeV-madgraph-tauola.log 
  #rm /hadoop/cms/store/user/$USERNAME/$shortName/crab_$longName/$CMS3tag/merged/*.root
  echo "Should resubmit here!! Fix me!!" 
  #python process.py $file $fileNumber $dateTime &
else
  #Copy to bad dir
  mkdir /hadoop/cms/store/group/snt/$thedir/$longName 2> /dev/null
  mkdir /hadoop/cms/store/group/snt/$thedir/$longName/$myDir 2> /dev/null
  mkdir /hadoop/cms/store/group/snt/$thedir/$longName/$myDir/bad/ 2> /dev/null
  #mv /hadoop/cms/store/user/$USERNAME/$shortName/crab_$longName/$CMS3tag/merged/*.root /hadoop/cms/store/group/snt/$thedir/$longName/$myDir/bad/
  echo "mv /hadoop/cms/store/user/$USERNAME/$shortName/crab_$longName/$CMS3tag/merged/*.root /hadoop/cms/store/group/snt/$thedir/$longName/$myDir/bad/"
  echo "$longName" >> crab_status_logs/copy.txt
  root -b -l -q numEventsROOT.C\(\"/hadoop/cms/store/group/snt/$thedir/$longName/$myDir\"\) >> crab_status_logs/copy.txt 2>&1
  #mv copy_log_$shortName.log /hadoop/cms/store/group/snt/$thedir/$longName/$myDir/bad/
fi
