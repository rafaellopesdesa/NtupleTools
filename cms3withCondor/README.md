This allows you to run CMS3 on the grid with Condor.  This is useful for privately-produced samples.

Instructions:
  - Packages cannot be added for some reason.  Instead, have to tar up the package and send it off. The only package you currently need is this one: RecoEgamma -- get it from a local, recently-installed copy of CMS3, tar it up, and put it in this directory with the name RecoEgamma.tar.  The code will take care of the rest
  - Need a list of files that you want to run on.  See files.txt for an example.  Further, you'll want to modify submit.sh line 17 to look in the right place -- currently it looks in one directory on eos.  
  - Type ". submit.sh". 

