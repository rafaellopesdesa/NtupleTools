#!/bin/bash

crontab -r
condor_rm $USER
sleep 10
rm /nfs-7/userdata/dataTuple/completedList.txt
rm /hadoop/cms/store/user/$USER/condor/dataNtupling/dataTuple/*.root
rm /home/users/$USER/NtupleTools/dataTuple/*.txt
rm -rf /home/users/$USER/NtupleTools/dataTuple/cms3withCondor
rm -rf /home/users/$USER/NtupleTools/dataTuple/cms3withCondor
