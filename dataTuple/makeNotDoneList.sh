#!/bin/bash

sort fakeMasterList.txt > temp.txt
mv temp.txt fakeMasterList.txt
sort fakeCompletedList.txt > temp.txt
mv temp.txt fakeCompletedList.txt
diff fakeMasterList.txt fakeCompletedList.txt > notDoneList.txt 
sed -i 's/<\ //g' notDoneList.txt
sed -i '1d' notDoneList.txt
