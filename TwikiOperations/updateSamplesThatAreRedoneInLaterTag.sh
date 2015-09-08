#!/bin/bash

#user set options
username=george
passwordFile=/home/users/$USER/.ssh/password.txt
fileWithUpdates=fromNick2.txt

#---HERE there be dragons-----
while read line
do
  sample=`echo "$line"  | awk {'print $2'}`
  tag=`echo "$line"  | awk {'print $3'}`
  shortTag=`echo $tag | cut -c 1-5 --complement`

  /usr/bin/python twiki.py $username --CMS3tag $tag --dataset $sample --location /hadoop/cms/store/group/snt/run2_25ns/$sample/V$shortTag --whichTwiki 2 --passwordFile $passwordFile

done < $fileWithUpdates
