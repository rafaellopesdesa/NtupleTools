This script checks which datasets are valid and not present at T2_US_UCSD, and lists them in an output file.

###Instructions:
  1. "/usr/bin/python twiki.py YOUR_TWIKI_LOGIN_NAME --allSamples 1".  
  - makes an inputfile allsamples.txt with a list of every sample on the twiki.
  2. Compile the macro in Root and run it
  
  ```
  $ root
  root[0] .L missingDatasets.C+
  root[1] missingDatasets()
  ```
  
  3. use output file to make a PhEDEx request (https://cmsweb.cern.ch/phedex/prod/Info::Main)
