#!/bin/bash

list=$1

echo "This is output from: $list"

while read line
do
line2=`echo "$line" | tr '/' ' '`
suffix=`echo "$line2" | awk '{print $3}'`
if [ "$suffix" != "MINIAODSIM" ]; 
then
  continue
fi
stuff=`echo $line2 | awk '{print $1}'`
stuff2=`echo $line2 | awk '{print $2}'`

first2=`echo $line2 | awk '{print $1}' | cut -c 1-2`
first3=`echo $line2 | awk '{print $1}' | cut -c 1-3`
first4=`echo $line2 | awk '{print $1}' | cut -c 1-4`
first5=`echo $line2 | awk '{print $1}' | cut -c 1-5`
first6=`echo $line2 | awk '{print $1}' | cut -c 1-6`
first7=`echo $line2 | awk '{print $1}' | cut -c 1-7`
first8=`echo $line2 | awk '{print $1}' | cut -c 1-8`
first9=`echo $line2 | awk '{print $1}' | cut -c 1-9`
first10=`echo $line2 | awk '{print $1}' | cut -c 1-10`
if  [ "$first2" == "LQ" ] || [ "$first6" == "Zprime" ] || [ "$first6" == "Wprime" ] || [ "$first2" == "RS" ] || [ "$first3" == "ADD" ] || [ "$first9" == "Displaced" ] || [ "$first5" == "Qstar" ] || [ "$first6" == "Unpart" ] || [ "$first6" == "Tprime" ] || [ "$first3" == "HSC" ] || [ "$first5" == "Bstar" ] || [ "$first2" == "WR" ] || [ "$first5" == "Regge" ] || [ "$first5" == "Tstar" ]  || [ "$first6" == "GluGlu" ] || [ "$first6" == "Bprime" ] || [ "$first8" == "BulkGrav" ]  || [ "$first6" == "WToENu" ] || [ "$first7" == "WToMuNu" ] || [ "$first8" == "WToTauNu" ] || [ "$first3" == "VBF" ] || [ "$first6" == "tGamma" ] || [ "$first7" == "Monotop" ] || [ "$first3" == "ZTo" ] || [ "$first6" == "GGJets" ] || [ "$first8" == "BdToJpsi" ] || [ "$first3" == "X53" ] || [ "$first6" == "Radion" ] || [ "$first10" == "DarkMatter" ] || [ "$first3" == "RPV" ] || [ "$first2" == "XX" ] || [ "$first7" == "Charged" ] || [ "$first3" == "DM_" ] || [ "$first7" == "Taustar" ] || [ "$first5" == "Estar" ] || [ "$first6" == "Mustar" ]  || [ "$first9" == "BlackHole" ] || [ "$first3" == "DMS" ] ||  [ "$first3" == "DMV" ] 

then
  continue
fi

if [[ "$stuff" == *"DoubleEMEnriched"* ]] || [[ "$stuff" == *"_mtop"* ]] || [[ "$line2" == *"scale"* ]] || [[ "$stuff" == *"BulkGrav"* ]] || [[ "$stuff" == *"DMJets"* ]] 
then
  continue
fi

if [[ "$stuff2" == *"-Asympt25ns_"* ]] || [[ "$stuff2" == *"-Asympt50ns_"* ]]  || [[ "$stuff2" == *"15FSPremix"* ]] 
then
  :
else
  continue
fi

echo "$line"
done < $list
