In principle, this should handle all aspects of CMS3 making, from submission to output in the user's hadoop directory.

Instructions:
  1. Clone the NTupleTools repository to an empty directory (git clone ssh://git@github.com/cmstas/NtupleTools AutoTupler)  Open a screen session. 
  2. In the NtupleTools/AutoTuple directory, write a text file called instructions.txt wih the instructions.  First line: global tag.  Second line: CMS3 tag.  Rest of file: 1 line per sample with the following columns, separated by spaces: name, xsec, k, isData (True or False), sparm names (optional).
  3. ". setup.sh instructions.txt" (no quotes)
  4. Monitor it fairly closely for ~30 mins or so (until the AutoTupleHQ page is available); it may ask for passwords, proxies, etc.  You can find the status page at http://uaf-7.t2.ucsd.edu/~USER/AutoTupleHQ.html, where USER is your username on the uaf
  5. When all jobs finished, copy to hadoop

To do:
  - Automatic copying to hadoop
  - Automatic making of instructions file from twiki
  - Directory structure in hadoop could be cleaned up, lots of long names
  - Status page is not perfect; should rethink how/when status page updated
  - Asks for grid pass phrase at beginning, bad.  Also, need to add protection for if pass phrase entered incorrectly
  - Support for "Error during task injection" errors -- have it attempt to resubmit N times. 
  - Seem to frequently get a "PhedEx" error which requires full delete-and-redo after ~1 h, should support this
  - Add cooloff, transferred, submitted to status list?
  - Some people have uaf names different than hadoop names, should support this.  

Awesome trick: Making the instructions.txt file is a little bit painful.  Here is an easy way:
  1. Check the twiki.  Make sure that ALL columns are filled in for your samples EXCEPT the numEvtsOut and the CMS3 location (you will have to modify step 3 below if this is not true).
  2. "Select All" on the twiki and paste into a new document, we'll call it twiki.txt
  3. Issue the following command (change to your name): awk 'NF > 4 && $9 == "Alex" {print $1 " " $4 " " $5 " False"}' twiki.txt > instructions.txt
  4. If any of your samples are data, change the last column to True.  If any of your samples are SUSY, add a new column with the susy sparms
  5. Add two lines to the top: the first contains the global tag, the second contains the CMS3 tag
