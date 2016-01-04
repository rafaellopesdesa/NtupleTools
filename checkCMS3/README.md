#checkCMS3
A macro to check certain trouble spots in CMS3 ntuples. It runs automatically when you use the AutoTupler. It can also be run manually, on the ROOT command line.

###To run this macro by hand:
Compile the macro in root, then run it, with the first argument (mandatory) being the path to the sample you want to check. This macro is designed to work both on merged and unmerged samples.

If you're checking a merged CMS3 sample, you can (optionally) put the path to the unmerged version as the second argument, and the macro will check to make sure that the merged and unmerged versions have the same number of events.

```
$ root
root[0] .L checkCMS3.C+
root[1] checkCMS3("/path/to/some/sample/directory/")
---or---
root[1] checkCMS3("/path/to/some/merged/sample/", "/optional/path/to/unmerged/version/")
```

Return value: the number of problems found.
Detailed printouts will highlight where any problems are found.

###Tests performed:
  - Detailed event counting
  - Printout of CMS3 tag
  - Consistency check between CMS3 tag and directory name
  - Detailed checks of post-processing variables
  - Checking for sParm branches

Send questions, comments, bugs, or feature requests to Dan Klein.
