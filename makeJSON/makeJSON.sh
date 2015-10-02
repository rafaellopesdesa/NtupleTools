#!/bin/bash

file=$1
BASEDIR=$2

end_name=`echo $file | tr '/' ' ' | awk '{print $NF}' | tr '.' ' ' | awk '{print $1}'` 
sample=`echo $file | tr '/' ' ' | awk '{print $(NF-3)}'`

root -b -q doIt.C\(\"$1\"\) > temp.txt
if [ "$2" == "" ]
then
  csv2json.py temp.txt > ${end_name}_json.txt
else
  if [ ! -d $BASEDIR/json_lists/$sample ]; then mkdir -p $BASEDIR/json_lists/$sample ; fi
  csv2json.py temp.txt > $BASEDIR/json_lists/$sample/${end_name}_json.txt
fi

mergeJSON.py $BASEDIR/json_lists/$sample/*_json.txt > $BASEDIR/json_lists/full_JSON_$sample.txt
