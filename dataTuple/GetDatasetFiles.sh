#!/bin/bash

#example usage:
#./GetDatasetFiles.sh /DYJetsToLL_M-50_13TeV-madgraph-pythia8/Phys14DR-PU20bx25_PHYS14_25_V1-v1/MINIAODSIM 

./das_client.py --query="file dataset= $1" | grep "^/store"
