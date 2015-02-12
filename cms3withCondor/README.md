This allows you to run CMS3 on the grid with Condor.  This is useful for privately-produced samples.

Instructions:
  - To set up, just modify the options at the top of submit.sh
  - To submit jobs, just type ". submit.sh".  
  - To resubmit jobs, just wait until all the jobs have finished running ("condor_q username" to check), then reissue step 2.  It automatically checks to see which ones have finished.  
  - To post-process jobs....

Options:
  - The MCProduction2015_NoFilter_cfg.py is the macro that will be run.  You can change it directly.
  - RecoEgamma.tar is just a tarred-up version of the RecoEgamma package.  You should update this every so often to pick up the latest changes.  

Technical Notes:
  - Packages cannot be added for some reason.  Instead, have to tar up the package and send it off. The only package you currently need is this one: RecoEgamma -- get it from a local, recently-installed copy of CMS3, tar it up, and put it in this directory with the name RecoEgamma.tar.  The code will take care of the rest
