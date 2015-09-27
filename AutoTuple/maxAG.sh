#!/bin/bash
maxAG(){
  max=0 
  for i in $@
  do
    if [ "$i" -gt "$max" ] ; then max=$i; fi
  done
  echo $max
}

maxAG $@
