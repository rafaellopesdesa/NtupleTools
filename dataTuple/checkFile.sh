#/bin/bash

root -b -q "isValidFile.C(\"$1\")" > validFileOutput.txt

readarray -t results < validFileOutput.txt
for i in "${results[@]}"
do
  if [ "$i" == "FileIsValid" ]; then
    echo $1 >> /nfs-7/userdata/dataTuple/completedList.txt
  fi
done
