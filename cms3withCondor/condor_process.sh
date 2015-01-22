#!/bin/bash

files=files.txt

while read line
do
  filedir=$line
  temp=`root -b -l -q getSparm.C\(\"$filedir\"\)`
  sparm_shit=`echo $temp | awk '{ print $NF }' | cut -c 1-5 --complement`
  sparm_class=`echo $sparm_shit | cut -c 1-2`
  sparm=`echo $sparm_shit | cut -c 1-2 --complement`
  sparm=$(expr $sparm + 0)
  
  if [ $sparm_class == "10" ] 
  then
    temp2=`root -l -b -q go_xsec.C\($sparm\)` 
  elif [ $sparm_class == "20" ]
  then
    temp2=`root -l -b -q stop_xsec.C\($sparm\)` 
  else
    echo "ERROR!  Only gluinos are supported!" 
    return;
  fi
  
  xsec=`echo $temp2 | awk '{ print $NF }' | cut -c 1-7 --complement`
  
  echo "cross section for $filedir is $xsec"
  python makeListsForMergingCrab3.py -d /hadoop/cms/store/user/$USER/condor/privateSignals/$filedir -o /hadoop/cms/store/user/$USER/condor/privateSignals/$filedir/merged/ -s $filedir -k 1 -e 1 -x $xsec --overrideCrab 
done < $files
