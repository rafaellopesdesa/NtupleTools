
int runAddBranches(const string &mData, const string &inFileName, const string &outFileName, const string &FWLite){
  
  if (FWLite.c_str() == ""){
	gSystem->Load("libMiniFWLite.so");
  }else{
	gSystem->Load(FWLite.c_str());
  }

  gROOT->ProcessLine(".L addBranches.C+");
  addBranches(mData, inFileName, outFileName);
  
 return 0;

}
