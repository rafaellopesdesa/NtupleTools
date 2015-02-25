#!/bin/bash

> masterList.txt

readarray -t samples < /nfs-7/userdata/dataTuple/input.txt
for i in "${samples[@]}"
do
  ./das_client.py --query="file dataset= $i" | grep "^/store" >> masterList.txt
done
