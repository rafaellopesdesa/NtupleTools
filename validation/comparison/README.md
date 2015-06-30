#Compare Ntuples for CMS3

This is a "core dump" of every branch in CMS3 for **TWO RELEASES**.  If you want one release by itself, you are looking for cmstas/NtupleTools/validation/branchDumper.  

###Instructions:
1. In do.C, put the OLD SAMPLE on line 5 and the NEW sample on line 5.  You should also decide if you want to do force it to draw even the identical histograms (arg3, true/false). The error bars in the New/Old comparison is currently forced enabled, future upgrade will make it optional (arg4, true/false).
2. A dataMCplotMaker is required. If you don't have yet, checkout https://github.com/cmstas/Software.git into the same directory as with NtupleTools. Or modify the path in both do.C and compareNtuples.C to the dataMCplotMaker. If you have any problem with the plots, check the README of dataMCplotMaker.
3. A hists subdirectory is required in comparison. 
4. "root -b do.C"
5. ". process.sh" 
6. Now overview.pdf has everything you need. The table of contents can be clicked to jump to the plots.

###Sample:
For run-2, we have been using the following sample for validation:
 - fileNames = cms.untracked.vstring('/store/mc/RunIISpring15DR74/TTJets_TuneCUETP8M1_13TeV-madgraphMLM-pythia8/MINIAODSIM/Asympt50ns_MCRUN2_74_V9A-v1/00000/20AD8065-31FD-E411-9D75-00259073E2F2.root')
