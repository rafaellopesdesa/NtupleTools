#/bin/bash

./sweepRoot -o Events -t Events $1 > validFileOutput.txt

readarray -t results < validFileOutput.txt
for i in "${results[@]}"
do
  if [ "$i" == "SUMMARY: 0 bad, 1 good" ]; then
    echo $2 >> /nfs-7/userdata/dataTuple/completedList.txt
    filename_escaped=`echo $2 | sed 's,/,\\\/,g'`
    sed -i "/$filename_escaped/d" submitList.txt
    if [ -e failureList.txt ]; then
      sed -i "/$filename_escaped/d" failureList.txt
    fi
    break;
  fi
  if [ "$i" == "SUMMARY: 1 bad, 0 good" ]; then
    rm $1
    echo $2 >> filesToSubmit.txt
    break;
  fi
done

