##CMS3 With Condor

This allows you to run CMS3 on the grid with Condor.  This is useful for privately-produced samples.  The DataTupler also checks this out, so be careful not to commit anything that will break the dataTuple.

Instructions:
  - You need all the file names of the form /store/foo/bar/blah.root.  This can be anything, even hadoop files!  Write a text file where the first line shows the directory (starting with /store...) and all subsequent lines are file names relative to that directory.  See hint [1] for a hint on making these lists
  - To set up and submit jobs, follow the comments at the top of runCMS3withCondor.sh.  Run that file to submit everything.  See hint [2]
  - To resubmit jobs, just wait until all the jobs have finished running ("condor_q username" to check), then reissue step 1.  It automatically checks to see which ones have finished.  
  - To post-process jobs, use the condor_process.py file.  All the options are present at the top (only for gluino and stop right now).

Hints:
  1. If the files you want to run are on eos, you can make a list of them like this:
    - for i in `eos ls /store/cmst3/group/susy/gpetrucc/13TeV/RunIISpring15DR74/*`; do echo "----${i}--------"; eos ls /store/cmst3/group/susy/gpetrucc/13TeV/RunIISpring15DR74/$i ; done 
    Note that you will still have to split them up by hand.  
  2.  The default (which I find useful) is to feed in the name (not the prefix or dir) of the files as an argument.  Then I script this in makePrivateSamples.sh.  
