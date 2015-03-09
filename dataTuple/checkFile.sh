#/bin/bash

root -b -q "isValidFile.C(\"$1\")" > validFileOutput.txt

readarray -t results < validFileOutput.txt
for i in "${results[@]}"
do
  if [ "$i" == "FileIsValid" ]; then
    echo $2 >> /nfs-7/userdata/dataTuple/completedList.txt
    break;
  fi
  if [ "$i" == "FileIsNotValid" ]; then
    rm $1
    echo $1 >> filesToSubmit.txt
    break;
  fi
done
