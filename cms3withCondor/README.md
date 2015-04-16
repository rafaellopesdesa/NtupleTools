##CMS3 With Condor

This allows you to run CMS3 on the grid with Condor.  This is useful for privately-produced samples.  The DataTupler also checks this out, so be careful not to commit anything that will break the dataTuple

Instructions:
  - To set up and submit jobs, follow the comments at the top of runCMS3withCondor.sh.  Run that file to submit everything.
  - To resubmit jobs, just wait until all the jobs have finished running ("condor_q username" to check), then reissue step 1.  It automatically checks to see which ones have finished.  
  - To post-process jobs, use the condor_process.py file.  All the options are present at the top (only for gluino and stop right now).

Options:
  - The pset.py is the macro that will be run.  For options that cannot be controlled from the macro, you can make changes directly.
