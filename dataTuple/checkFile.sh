#/bin/bash

BASEPATH=$1

if [ ! -d $BASEPATH ]
then
  echo "BASEPATH in checkFile.sh does not exist!"
fi

./sweepRoot -o Events -t Events $2 > validFileOutput.txt

readarray -t results < validFileOutput.txt
for i in "${results[@]}"
do
  if [ "$i" == "SUMMARY: 0 bad, 1 good" ]; then
    echo $2 >> $BASEPATH/fileLists/`date +%F`.txt
    echo $3 >> $BASEPATH/completedList.txt
    filename_escaped=`echo $3 | sed 's,/,\\\/,g'`
    sed -i "/$filename_escaped/d" submitList.txt
    if [ -e failureList.txt ]; then
      sed -i "/$filename_escaped/d" failureList.txt
    fi
    break;
  elif [ "$i" == "SUMMARY: 1 bad, 0 good" ]; then
    rm $2
    echo $3 >> filesToSubmit.txt
    break;
  fi
done
