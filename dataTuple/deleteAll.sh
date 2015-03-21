#!/bin/bash

crontab -r
condor_rm $USER
sleep 10
rm /nfs-7/userdata/dataTuple/completedList.txt
rm /nfs-7/userdata/dataTuple/dataTuple.log
rm -rf /hadoop/cms/store/user/$USER/condor/dataNtupling/*
rm /home/users/$USER/NtupleTools/dataTuple/*.txt
rm -rf /home/users/$USER/NtupleTools/dataTuple/cms3withCondor
rm -rf /home/users/$USER/NtupleTools/dataTuple/cms3withCondor
