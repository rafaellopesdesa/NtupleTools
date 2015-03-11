#!/bin/bash

comm -13 <(sort /nfs-7/userdata/dataTuple/completedList.txt) <(sort masterList.txt) > notDoneList.txt
