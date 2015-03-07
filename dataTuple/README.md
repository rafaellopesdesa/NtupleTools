# DataTuple

####General Outline
  + User updates samples we want to check here: /nfs-7/userdata/dataTuple/input.txt
  + List of samples we have completed is here: /nfs-7/userdata/dataTuple/completedList.txt
  + Every 3 minutes, manager.py is called and the below workflow begins again.

####Workflow
  1. DBS query to generate masterList with files on input.txt (JASON)
  2. Diff between masterList and completedList to make notDoneList.  
  3. condor_q makes runningList and heldList.  Jobs on the heldList are killed.  
  4. Cycle through files on notDoneList.  
    1. See if each job is on failureList.  If yes, continue
    2. See if each job is on submitList.  If no, mark job for submission and on to step 5. 
    3. Otherwise, it's on the submitList.  Get the jobID from there and see if the job is running. 
    4. If job is on run list, check time.  If has been running for more than 24 hours, kill it, mark for submission, and on to step 5. 
    5. If not on run list, check if it's done.  If not done, mark for submission and on to step 5.
    6. If job is done, do quality checks.  If fails, delete the output, mark for submission, and on to step 5. (JASON)
    7. If passes quality checks, then update the done list and we're done. (JASON)
  5. Submit all jobs marked for submission. 
    1. Submit them
    2. Verify jobs submitted properly
    3. Update submit list

####To Do:
  1. Right now, all ntuples go to the same directory, should change directory structure.  
  2. Make sure only one instance of manager can run at a time.
  3. Add ability to run on multiple UAFs in case one goes down.
