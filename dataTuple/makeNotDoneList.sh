#!/bin/bash

sort masterList.txt > temp.txt
mv temp.txt masterList.txt
sort completedList.txt > temp.txt
mv temp.txt completedList.txt
diff masterList.txt completedList.txt > notDoneList.txt 
sed -i 's/<\ //g' notDoneList.txt
sed -i '1d' notDoneList.txt
