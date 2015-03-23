In principle, this should handle all aspects of CMS3 making, from submission to output in the user's hadoop directory.

Instructions:
  1. Clone the NTupleTools repository to an empty directory (git clone ssh://git@github.com/cmstas/NtupleTools AutoTupler)  Open a screen session. 
  2. In the NtupleTools/AutoTuple directory, write a text file called instructions.txt wih the instructions.  First line: global tag.  Second line: CMS3 tag.  Rest of file: 1 line per sample with the following columns, separated by spaces: name, xsec, k, isData (True or False), sparm names (optional).  Hint: see the "awesome trick" below!
  3. ". setup.sh instructions.txt" (no quotes)
  4. Monitor it fairly closely for ~30 mins or so (until the AutoTupleHQ page is available); it may ask for passwords, proxies, etc.  You can find the status page at http://uaf-7.t2.ucsd.edu/~USER/AutoTupleHQ.html, where USER is your username on the uaf
  5. When all jobs finished, copy to hadoop.  You can do this manually or with ". copy.sh /SAMPLENAME/foo/bar CMS3_V07-0X-YY" (the latter way will tell you the location and the nEvents copied).  

To restart:
  - If you interrupt it, can restart monitoring with ". monitor.sh insturctions.txt" (no quotes)

To post-process by itself
  - If you just want to post-process, you can do "python process.py instructions.py 4" where 4 is the line number on the instructions file that you want to post-process.  This will only work if you made the original crab jobs using the AutoTupler (or you used the same directory structure that the AutoTupler uses).  

Awesome trick: Making the instructions.txt file is a little bit painful.  Here is an easy way:
  1. Check the twiki.  Make sure that ALL columns are filled in for your samples EXCEPT the numEvtsOut and the CMS3 location (you will have to modify step 3 below if this is not true).
  2. "Select All" on the twiki; copy and paste into a new document, we'll call it twiki.txt
  3. Issue the following command (change to your name): awk 'NF > 4 && $9 == "Alex" {print $1 " " $4 " " $5 " False"}' twiki.txt > instructions.txt
  4. In the instructions.txt file: if any of your samples are data, change the last column for that sample to True.  If any of your samples are SUSY, add a fifth column with the susy sparms
  5. Add two lines to the top of the instructions.txt file: the first contains the global tag, the second contains the CMS3 tag

AutoTupler development -- to do list:
  - Automatic making of instructions file from twiki
  - Status page is not perfect; should rethink how/when status page updated
  - Asks for grid pass phrase at beginning, bad.  Also, need to add protection for if pass phrase entered incorrectly
  - Support for "Error during task injection" errors -- have it attempt to resubmit N times. 
  - Seem to frequently get a "PhedEx" error which requires full delete-and-redo after ~1 h, should support this
  - Add cooloff, transferred, submitted, unsubmitted to status list?
