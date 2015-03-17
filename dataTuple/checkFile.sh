#/bin/bash

./sweepRoot -t Events $1

readarray -t results < validFileOutput.txt
for i in "${results[@]}"
do
  if [ "$i" == "FileIsValid" ]; then
    echo $2 >> /nfs-7/userdata/dataTuple/completedList.txt
    break;
  fi
  if [ "$i" == "FileIsNotValid" ]; then
    rm $1
    echo $2 >> filesToSubmit.txt
    break;
  fi
done

#remove file from submitList.txt
filename_escaped=`echo $2 | sed 's,/,\\\/,g'`
sed -i "/$filename_escaped/d" submitList.txt
