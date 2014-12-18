In principle, this should handle all aspects of CMS3 making, from submission to output in the user's hadoop directory.

Instructions:
  1. Clone this repository to an empty directory.  Type: source /cvmfs/cms.cern.ch/crab3/crab.sh.  Open a screen session. 
  2. Write a text file wih the instructions, separated by spaces, one sample on each line.  Columns are: name, xsec, k, CMS3version, gtag, isData (True or False), sparm names (optional).
  3. ". setup.sh instructions.txt" (no quotes), where instructions.txt is the file from part 2.
  4. Monitor it fairly closely for ~30 mins or so (until the AutoTupleHQ page is available), may ask for passwords, proxies, etc.

To do:
  - Is it supported when there are more than 500 jobs?  
  - Directory structure in hadoop could be cleaned up, lots of long names
  - Move repo to cmstools?  Have to think about what to do with existing tools
  - Asks for grid pass phrase at beginning, bad.  Also, need to add protection for if pass phrase entered incorrectly
  - Support for "Error during task injection" errors -- have it attempt to resubmit N times. 
  - Seem to frequently get a "PhedEx" error which requires full delete-and-redo after ~1 h, should support this
  - Add cooloff, transferred to status list?
  - Support (or at least instructions) for adding jobs in the middle?
