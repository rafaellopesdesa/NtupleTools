#!/bin/bash

if [ $# -eq 0 ] 
  then 
    echo "No BASEPATH specified in GenerateMasterList.sh!"
    exit
  else
    BASEPATH=$1
fi

if [ ! -d $BASEPATH ]
then
  echo "BASEPATH in GenerateMasterList.sh does not exist!"
fi

> masterList.txt

readarray -t samples < $BASEPATH/input.txt
for i in "${samples[@]}"
do
  input_from_das=`./das_client.py --query="file dataset= $i site=T2_US_*"` #need to use --limit=0 to pick up all files!
  echo "$input_from_das" | grep "status: fail"
  if [ $? == 0 ]
  then 
    echo "failed" >> nQueryAttempts.txt
    if [ -e nQueryAttemts.txt ] && [ "$(cat nQueryAttempts.txt | wc -l)" -gt "60" ]; then echo "DataTupleWarning! Query attempt has failed many times!" | /bin/mail -r "george@physics.ucsb.edu" -s "[dataTuple] error report" "george@physics.ucsb.edu, jgran@physics.ucsb.edu"; fi
  else
    rm nQueryAttempts.txt &>/dev/null
  fi
  echo "$input_from_das" | grep "^/store" >> masterList.txt
done
