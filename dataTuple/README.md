# DataTuple

####General Outline
  User updates samples we want to check here: /nfs-7/userdata/dataTuple/input.txt
  List of samples we have completed is here: /nfs-7/userdata/dataTuple/completedList.txt
  Every 3 minutes, the below workflow begins again:

####Workflow
  1. DBS query to generate masterList with files on input.txt (JASON)
  2. Diff between masterList and completedList to make notDoneList
  3. condor_q makes runningList and heldList.  Jobs on the heldList are killed.  
  4. Cycle through files on notDoneList.  
    1. See if each job is on submitList.  If no, submit it, update the submit list, and we're done.  
    2. Otherwise, it's on the submitList.  Get the jobID from there and see if the job is running. 
    3. If job is on run list, check time.  If has been running for more than 24 hours, kill it.
    4. If not on run list, check if it's done.  If not done, submit it, update the submit list, and we're done.
    5. If job is done, do quality checks.  If fails, delete the output and we're done. If passes, then update the done list and we're done.  (JASON)  
