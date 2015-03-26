#!/bin/bash

if (( $# != 1 )); then
  echo "Illegal number of arguments."
  echo "Must provide CMS3 tag"
  exit 1
else
  THE_CMS3_TAG=$1
fi

echo "Checkout and build CMS3:"

curl https://raw.githubusercontent.com/cmstas/NtupleMaker/master/install.sh > install.sh

sed -i "s/CMS3Tag=master/CMS3Tag=${THE_CMS3_TAG}/g" install.sh

DIR=$PWD

source install.sh
cd $CMSSW_BASE
echo "Making the tarball..."
tar -chzvf lib_$THE_CMS3_TAG.tar.gz lib/ python/ src/CMS3/NtupleMaker/test/MCProduction2015_NoFilter_cfg.py

mv lib_$THE_CMS3_TAG.tar.gz $DIR/lib_$THE_CMS3_TAG.tar.gz
cd $DIR
echo "Your tarball is lib_$THE_CMS3_TAG.tar.gz"
