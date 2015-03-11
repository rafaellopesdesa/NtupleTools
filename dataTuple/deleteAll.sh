#!/bin/bash

crontab -r
condor_rm cgeorge
sleep 10
rm /nfs-7/userdata/dataTuple/completedList.txt
rm /hadoop/cms/store/user/cgeorge/condor/dataNtupling/dataTuple/*.root
rm /home/users/cgeorge/NtupleTools/dataTuple/*.txt
rm -rf /home/users/cgeorge/NtupleTools/dataTuple/cms3withCondor
rm -rf /home/users/cgeorge/NtupleTools/dataTuple/cms3withCondor
