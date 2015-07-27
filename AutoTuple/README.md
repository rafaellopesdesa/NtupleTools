#AutoTupler

In principle, this should handle all aspects of CMS3 making, from submission to output in the group's hadoop directory.

###Instructions:
  0. Update the twiki with all the cross-sections, k factors, etc. 
    - You can use the getXsec directory for this
    - the cross-section should always match MCM (unless MCM is meaningless); the kfactor should address any needed corrections.  Add a comment to explain if your k-factor is not unity.
  1. Clone the NTupleTools repository to an empty directory (git clone ssh://git@github.com/cmstas/NtupleTools)  Open a screen session. 
  2. "/usr/bin/python twiki.py YOUR_TWIKI_LOGIN_NAME --makeInstructions NAME_IN_ASSIGNED_COLUMN_ON_TWIKI".  
    - For example, Alex would use "george" for the first name, because that's how he logs into the twiki, and "Alex" for the second name, because that's what his samples are assigned to.  This will create instructions.txt using samples assigned to name NAME.  Alternatively, you can write this by hand, see instructions.txt in this repo for example.
  3. ". setup.sh instructions.txt" (no quotes)
  4. Monitor it fairly closely for ~5 mins or so (until the AutoTupleHQ page is available); it may ask for passwords, proxies, etc.  You can find the status page at http://uaf-7.t2.ucsd.edu/~USER/AutoTupleHQ.html, where USER is your username on the uaf
  5. When all jobs finished, use twiki.py to update the twiki, or you can do it manually.  Make sure it was copied successfully to hadoop and is not in a /bad/ subdirectory, which indicates that there were problems.  

###To inject new jobs after you started the AutoTupler:
- Stop monitor.sh
- Modify your instructions files (Adding lines or correcting typos) in your crab directory. 
- Resume monitor.sh with the new instructions file with ". monitor.sh instructions.txt" (no quotes). The AutoTupler should find any new datasets and create tasks for them if they do not yet exist.
- WARNING: Make sure the datasets you add have the same tags! The current version of the Autotupler only supports instructions files where all datasets use the same tags.

###To restart:
  - If you interrupt it, can resume with ". monitor.sh instructions.txt" (no quotes)

###To post-process by itself
  - If you just want to post-process, you can do "python process.py instructions.py 4" where 4 is the line number on the instructions file that you want to post-process.  This will only work if you made the original crab jobs using the AutoTupler (or you used the same directory structure that the AutoTupler uses).  

###Other Twiki.py usage.  
First argument is your twiki username.  Then you'll need at least one optional argument, depending on what you want to do.  There are three modes in which you can run this:
  - Manual.  --manual 1 will download two copies of the twiki.  You can then make changes manually and upload by calling the script with --manual 2
  - Instructions.  --makeInstructions name will make the instructions.py file for the person named "name".  You should check this carefully.  Note that data samples are not currently supported.  
  - Modify.  --dataset to specify the dataset you want to modify, then one of the other options (ex: --xsec 500) to change the value in question.  --help to get a list of the allowed options.  You'll have to enter your password each time.  

Note: In principle, you can write scripts that call twiki.py and even feed the password in.  Be VERY careful with these, it's easy to overwrite the twiki.  

###AutoTupler development -- to do list:
  - none!!

###AutoTupler -- (far) Future Development (good projects for undergrads, etc.)
  - Add line-by-line global/CMS3 tags
  - Print a document for each sample containing the absolute path of the MINAODSIM file for each job, so we can manually run on the job if it fails repeatedly
  - Integrate twiki.py into this (carefully) 
  - Consider more efficient ways to do the checking (ex: if nEventsInUnmerged != nEventsFromDAS, don't bother post-processing)
