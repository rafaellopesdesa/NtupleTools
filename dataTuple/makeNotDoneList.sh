#!/bin/bash

sort masterList.txt > temp_masterList.txt
mv temp_masterList.txt masterList.txt
sort completedList.txt > temp_completedList.txt
mv temp_completedList.txt completedList.txt
diff masterList.txt completedList.txt > notDoneList.txt 
sed -i 's/<\ //g' notDoneList.txt
sed -i '1d' notDoneList.txt
