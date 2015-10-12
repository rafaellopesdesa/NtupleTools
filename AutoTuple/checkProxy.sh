#!/bin/bash

voms-proxy-info --all &> voms_status.txt

if grep "Couldn't find a valid proxy." voms_status.txt &>/dev/null
then 
  echo "Error!! You don't have a valid proxy!"
  return 1
fi

linesWithTimeLeft=`sed -n /timeleft/= voms_status.txt`
lineWithTimeLeft=`echo $linesWithTimeLeft | awk '{print $NF}'`
lineWithPath=`sed -n /path/= voms_status.txt`
hoursLeftOnProxy=`awk -v var="$lineWithTimeLeft" 'NR==var {print $3}' voms_status.txt | tr ':' ' ' | awk '{print $1}'`
pathToProxy="/home/users/$USER/.globus/proxy_for_$USER.file"
if [ `echo $(( ($hoursLeftOnProxy) < 4))` == 1 ]
then
  voms-proxy-init -q -voms cms -hours 120 -valid=120:0 -cert=$pathToProxy
fi
echo "Your proxy looks A-OK!!" 
