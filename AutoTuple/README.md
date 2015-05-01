In principle, this should handle all aspects of CMS3 making, from submission to output in the user's hadoop directory.

Instructions:
  1. Clone the NTupleTools repository to an empty directory (git clone ssh://git@github.com/cmstas/NtupleTools AutoTupler)  Open a screen session. 
  2. "python twiki.py YOUR_TWIKI_USERNAME --makeInstructions NAME".  This will create instructions.txt using samples assigned to nme NAME.  Alternatively, you can write this by hand, see instructions.txt in this repo for example.
  3. ". setup.sh instructions.txt" (no quotes)
  4. Monitor it fairly closely for ~30 mins or so (until the AutoTupleHQ page is available); it may ask for passwords, proxies, etc.  You can find the status page at http://uaf-7.t2.ucsd.edu/~USER/AutoTupleHQ.html, where USER is your username on the uaf
  5. When all jobs finished, copy to hadoop.  You can do this manually or with ". copy.sh /SAMPLENAME/foo/bar CMS3_V07-0X-YY" (the latter way will tell you the location and the nEvents copied).  Use twiki.py to update the twiki, or you can do it manually.

To restart:
  - If you interrupt it, can resume with ". monitor.sh insturctions.txt" (no quotes)

To post-process by itself
  - If you just want to post-process, you can do "python process.py instructions.py 4" where 4 is the line number on the instructions file that you want to post-process.  This will only work if you made the original crab jobs using the AutoTupler (or you used the same directory structure that the AutoTupler uses).  

Twiki.py usage.  First argument is your twiki username.  Then you'll need at least one optional argument, depending on what you want to do.  There are three modes in which you can run this:
  - Manual.  --manual 1 will download two copies of the twiki.  You can then make changes manually and upload by calling the script with --manual 2
  - Instructions.  --makeInstructions name will make the instructions.py file for the person named "name".  You should check this carefully.  Note that data samples are not currently supported.  
  - Modify.  --dataset to specify the dataset you want to modify, then one of the other options (ex: --xsec 500) to change the value in question.  --help to get a list of the allowed options.  You'll have to enter your password each time.  
Note: In principle, you can write scripts that call twiki.py and even feed the password in.  Be VERY careful with these, it's easy to overwrite the twiki.  

AutoTupler development -- to do list:
  - Should look at logs to get nEvents
