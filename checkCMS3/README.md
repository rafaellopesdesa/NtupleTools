#checkCMS3
A macro to check certain trouble spots in CMS3 ntuples

###To use:
Compile the macro in root, then run it, with the path to a CMS3 sample as the only argument.
This macro is designed to work both on merged and unmerged samples.

$ root
root[0] .L checkCMS3.C+
root[1] checkCMS3("/path/to/some/sample/directory/")

Return value: the number of problems found.
Detailed printouts will highlight where any problems are found.

###Tests performed:
  - Detailed event counting
  - Printout of CMS3 tag
  - Detailed checks of post-processing variables
  - Checking for sParm branches

Send questions, comments, bugs, or feature requests to Dan Klein.