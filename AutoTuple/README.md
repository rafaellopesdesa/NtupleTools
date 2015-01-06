In principle, this should handle all aspects of CMS3 making, from submission to output in the user's hadoop directory.

Instructions:
  1. Clone this repository to an empty directory.  Open a screen session. 
  2. Write a text file called instructions.txt wih the instructions.  First line: global tag.  Second line: CMS3 tag.  Rest of file: 1 line per sample with the following columns, separated by spaces: name, xsec, k, isData (True or False), sparm names (optional).
  3. ". setup.sh instructions.txt" (no quotes)
  4. Monitor it fairly closely for ~30 mins or so (until the AutoTupleHQ page is available); it may ask for passwords, proxies, etc.  You can find the status page at http://uaf-7.t2.ucsd.edu/~USER/AutoTupleHQ.html, where USER is your username on the uaf

To do:
  - Directory structure in hadoop could be cleaned up, lots of long names
  - Status page is not perfect; should rethink how/when status page updated
  - Asks for grid pass phrase at beginning, bad.  Also, need to add protection for if pass phrase entered incorrectly
  - Support for "Error during task injection" errors -- have it attempt to resubmit N times. 
  - Seem to frequently get a "PhedEx" error which requires full delete-and-redo after ~1 h, should support this
  - Add cooloff, transferred, submitted to status list?
  - Some people have uaf names different than hadoop names, should support this.  
